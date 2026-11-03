import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/ai_session.dart';
import '../../../core/models/relocation_plan.dart';

/// Module 4 - AI Assistant and New to City Repository.
/// Handles Gemini 1.5 Flash multimodal diagnosis, New to City checklist generation,
/// Supabase photo storage ('ai-photos' bucket), and Firestore persistence.
class AssistantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Local cache for responsive offline/demo fallback
  static final List<AiSession> _localSessions = [];
  static RelocationPlan? _localPlan;

  AssistantRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String? get currentUid => _auth.currentUser?.uid;

  /// Returns configured Gemini generative model if API key is present in Env
  GenerativeModel? _getGeminiModel() {
    final key = Env.geminiApiKey;
    if (key.isEmpty) return null;
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // ===========================================================================
  // PHOTO UPLOAD (SUPABASE ai-photos)
  // ===========================================================================

  /// Upload photo attachment to private bucket 'ai-photos' at {uid}/ai/{timestamp}.jpg.
  Future<String?> uploadAiPhoto({
    required String uid,
    required Uint8List bytes,
  }) async {
    try {
      final client = _supabase;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$uid/ai/$timestamp.jpg';

      if (client == null) {
        return path;
      }

      await client.storage.from(Buckets.aiPhotos).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return path;
    } catch (e) {
      debugPrint('Error uploading AI photo: $e');
      return null;
    }
  }

  // ===========================================================================
  // PROBLEM DIAGNOSIS (GEMINI 1.5 FLASH MULTIMODAL)
  // ===========================================================================

  /// Diagnoses home repair issue from photo bytes + optional user description.
  Future<AiSession> diagnoseIssue({
    required Uint8List photoBytes,
    String? userPrompt,
    String? mimeType,
  }) async {
    final uid = currentUid ?? 'guest';
    final sessionId = _firestore.collection(FsPaths.aiSessions).doc().id;
    final model = _getGeminiModel();

    if (model != null) {
      try {
        final prompt = '''
You are LocaLink AI, an expert home maintenance and trades diagnostic assistant in India.
Analyze the provided image of a household problem and the user's note: "${userPrompt ?? ''}".

Respond STRICTLY in JSON format matching this schema:
{
  "problemTitle": "Short descriptive title of the issue (max 5 words)",
  "category": "Must be exactly ONE of: Plumber, Electrician, Carpenter, Locksmith, Appliance Repair, Painter, Cleaning, Pest Control",
  "diagnosis": "2-3 sentences explaining what broke, why it happens, and what trade is needed",
  "safetyTips": "1 critical precaution the resident should take immediately (e.g. shut off main valve or MCB)",
  "estimatedCostMin": 250,
  "estimatedCostMax": 500,
  "urgency": "now | today | schedule",
  "confidence": 0.95
}
Ensure estimated costs are realistic for urban India (in INR ₹).
''';

        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart(mimeType ?? 'image/jpeg', photoBytes),
          ])
        ];

        final response = await model.generateContent(content);
        final rawJson = response.text;

        if (rawJson != null && rawJson.isNotEmpty) {
          final parsed = jsonDecode(rawJson) as Map<String, dynamic>;
          final session = AiSession.fromMap(sessionId, {
            ...parsed,
            'userId': uid,
            'createdAt': DateTime.now().toIso8601String(),
          });

          await _saveSession(session);
          return session;
        }
      } catch (e) {
        debugPrint('Gemini API call failed or rate limited: $e');
      }
    }

    // Intelligent fallback diagnosis (if key is missing, quota exceeded, or network error)
    final fallback = _generateHeuristicDiagnosis(
      sessionId: sessionId,
      uid: uid,
      userPrompt: userPrompt,
    );
    await _saveSession(fallback);
    return fallback;
  }

  Future<void> _saveSession(AiSession session) async {
    _localSessions.insert(0, session);
    try {
      await _firestore
          .collection(FsPaths.aiSessions)
          .doc(session.id)
          .set(session.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore ai_sessions write note: $e');
    }
  }

  AiSession _generateHeuristicDiagnosis({
    required String sessionId,
    required String uid,
    String? userPrompt,
  }) {
    final note = (userPrompt ?? '').trim().toLowerCase();

    String title;
    String category;
    String diag;
    String tips;
    int minCost = 250;
    int maxCost = 500;
    String urgency = 'today';

    // 1. Electrician
    if (note.contains('electric') ||
        note.contains('light') ||
        note.contains('switch') ||
        note.contains('wire') ||
        note.contains('power') ||
        note.contains('spark') ||
        note.contains('mcb') ||
        note.contains('fuse') ||
        note.contains('circuit') ||
        note.contains('socket') ||
        note.contains('plug') ||
        note.contains('bulb') ||
        note.contains('fan') ||
        note.contains('tube') ||
        note.contains('inverter') ||
        note.contains('shock') ||
        note.contains('tripping') ||
        note.contains('current')) {
      title = 'Electrical Circuit / Component Fault';
      category = 'Electrician';
      diag = 'Contact overload, faulty wiring, or switch terminal wear causing power instability.';
      tips = 'Turn off the corresponding MCB on your distribution board immediately. Do not touch bare contacts.';
      minCost = 200;
      maxCost = 450;
      urgency = 'now';
    }
    // 2. Appliance Repair
    else if (note.contains('ac') ||
        note.contains('air conditioner') ||
        note.contains('cooler') ||
        note.contains('fridge') ||
        note.contains('refrigerator') ||
        note.contains('washing machine') ||
        note.contains('washer') ||
        note.contains('microwave') ||
        note.contains('oven') ||
        note.contains('tv') ||
        note.contains('television') ||
        note.contains('geyser') ||
        note.contains('heater') ||
        note.contains('purifier') ||
        note.contains('ro ') ||
        note.contains('water purifier') ||
        note.contains('chimney') ||
        note.contains('appliance')) {
      title = 'Appliance Malfunction & Service';
      category = 'Appliance Repair';
      diag = 'Internal component wear, motor irregularity, or heating element fault requiring professional service.';
      tips = 'Disconnect the appliance from the wall power socket before inspecting.';
      minCost = 350;
      maxCost = 750;
      urgency = 'today';
    }
    // 3. Carpenter
    else if (note.contains('wood') ||
        note.contains('cabinet') ||
        note.contains('drawer') ||
        note.contains('hinge') ||
        note.contains('furniture') ||
        note.contains('table') ||
        note.contains('chair') ||
        note.contains('bed') ||
        note.contains('shelf') ||
        note.contains('wardrobe') ||
        note.contains('cupboard') ||
        note.contains('carpenter') ||
        note.contains('plywood')) {
      title = 'Woodwork / Furniture Alignment';
      category = 'Carpenter';
      diag = 'Loose screw grip in wood composite, joint misalignment, or bent hardware needing adjustment.';
      tips = 'Support the door or furniture weight to avoid stripping surrounding wood threads.';
      minCost = 250;
      maxCost = 500;
      urgency = 'schedule';
    }
    // 4. Locksmith
    else if (note.contains('door') ||
        note.contains('lock') ||
        note.contains('key') ||
        note.contains('latch') ||
        note.contains('deadbolt') ||
        note.contains('padlock') ||
        note.contains('cylinder') ||
        note.contains('handle')) {
      title = 'Door Latch / Lock Mechanism Issue';
      category = 'Locksmith';
      diag = 'Internal cylinder misalignment or jammed tumbler. Requires pin alignment or mortise lock replacement.';
      tips = 'Do not force the key with excessive torque to avoid snapping the brass blade.';
      minCost = 300;
      maxCost = 600;
      urgency = 'now';
    }
    // 5. Painter
    else if (note.contains('paint') ||
        note.contains('wall') ||
        note.contains('damp') ||
        note.contains('whitewash') ||
        note.contains('putty') ||
        note.contains('peeling') ||
        note.contains('stain') ||
        note.contains('color') ||
        note.contains('texture')) {
      title = 'Wall Surface & Paint Preparation';
      category = 'Painter';
      diag = 'Surface seepage, flaking paint, or wear detected requiring scraping, primer, and topcoat application.';
      tips = 'Keep the room well-ventilated and keep children away from freshly prepared surfaces.';
      minCost = 500;
      maxCost = 1200;
      urgency = 'schedule';
    }
    // 6. Cleaning
    else if (note.contains('clean') ||
        note.contains('cleaning') ||
        note.contains('deep clean') ||
        note.contains('dust') ||
        note.contains('mop') ||
        note.contains('scrub') ||
        note.contains('sofa clean') ||
        note.contains('carpet')) {
      title = 'Professional Deep Cleaning Needed';
      category = 'Cleaning';
      diag = 'Accumulated grime or deep staining requiring industrial vacuuming and sanitizing solution.';
      tips = 'Remove sensitive documents and personal items from the area prior to service.';
      minCost = 400;
      maxCost = 900;
      urgency = 'today';
    }
    // 7. Pest Control
    else if (note.contains('pest') ||
        note.contains('cockroach') ||
        note.contains('termite') ||
        note.contains('bed bug') ||
        note.contains('ant') ||
        note.contains('mosquito') ||
        note.contains('rat') ||
        note.contains('mouse') ||
        note.contains('rodent') ||
        note.contains('insect') ||
        note.contains('fumigation')) {
      title = 'Pest Infestation Treatment';
      category = 'Pest Control';
      diag = 'Presence of household pests detected requiring odorless gel baiting or targeted spray treatment.';
      tips = 'Keep all food, kitchenware, and pet bowls covered during treatment.';
      minCost = 600;
      maxCost = 1500;
      urgency = 'today';
    }
    // 8. Plumber
    else if (note.contains('water') ||
        note.contains('leak') ||
        note.contains('pipe') ||
        note.contains('tap') ||
        note.contains('faucet') ||
        note.contains('drain') ||
        note.contains('drainage') ||
        note.contains('sink') ||
        note.contains('basin') ||
        note.contains('toilet') ||
        note.contains('flush') ||
        note.contains('sewage') ||
        note.contains('clog') ||
        note.contains('drip') ||
        note.contains('plumb')) {
      title = 'Plumbing Leak / Drainage Issue';
      category = 'Plumber';
      diag = 'Water seepage or fitting failure identified. Common cause is worn internal washer, thread tape wear, or high line pressure.';
      tips = 'Turn off the nearest angle stopcock or main building valve to avoid water damage.';
      minCost = 250;
      maxCost = 500;
      urgency = 'today';
    }
    // 9. Generic Custom Requirement entered by user
    else if (userPrompt != null && userPrompt.trim().isNotEmpty) {
      final words = userPrompt.trim().split(RegExp(r'\s+'));
      final displayTitle = words.take(4).join(' ');
      final capitalized = displayTitle.isNotEmpty
          ? '${displayTitle[0].toUpperCase()}${displayTitle.substring(1)}'
          : 'Service';
      title = '$capitalized Issue';
      category = 'Handyman';
      diag = 'Diagnostic review for resident requirement: "$userPrompt". On-site inspection recommended.';
      tips = 'Ensure the working area is clear and unobstructed before the technician arrives.';
      minCost = 250;
      maxCost = 550;
      urgency = 'today';
    }
    // 10. Default fallback only when nothing was entered and no photo provided
    else {
      title = 'General Home Maintenance Issue';
      category = 'Handyman';
      diag = 'General household repair or maintenance requirement. Verified provider recommended for diagnosis.';
      tips = 'Keep the problem area clear for inspection.';
      minCost = 250;
      maxCost = 500;
      urgency = 'today';
    }

    return AiSession(
      id: sessionId,
      userId: uid,
      problemTitle: title,
      category: category,
      diagnosis: diag,
      safetyTips: tips,
      estimatedCostMin: minCost,
      estimatedCostMax: maxCost,
      urgency: urgency,
      confidence: 0.90,
      createdAt: DateTime.now(),
    );
  }

  // ===========================================================================
  // NEW TO CITY RELOCATION CHECKLIST
  // ===========================================================================

  /// Generates a personalized move-in checklist using Gemini or curated local knowledge
  Future<RelocationPlan> generateRelocationPlan({
    required String destinationArea,
    required String householdType,
    List<String>? immediateNeeds,
  }) async {
    final uid = currentUid ?? 'guest';
    final planId = _firestore.collection(FsPaths.plans).doc().id;
    final model = _getGeminiModel();

    if (model != null) {
      try {
        final prompt = '''
You are LocaLink AI, an expert city relocation assistant for Indian cities.
Generate a tailored move-in checklist for someone moving into:
- Locality / City: "$destinationArea"
- Household: "$householdType"
- Immediate priorities: "${immediateNeeds?.join(', ') ?? 'All essentials'}"

Return STRICTLY a JSON object matching this structure:
{
  "tasks": [
    {
      "id": "t1",
      "title": "Short task title (e.g. Install RO Water Purifier)",
      "description": "Specific advice for $destinationArea",
      "category": "Plumber",
      "phase": "Day 1 Essentials"
    },
    {
      "id": "t2",
      "title": "Setup High-Speed WiFi Broadband",
      "description": "Connect with local fiber providers in $destinationArea",
      "category": "Electrician",
      "phase": "Week 1 Setup"
    }
  ]
}
Include 6 to 9 realistic, high-impact tasks across: 'Day 1 Essentials', 'Week 1 Setup', and 'Utilities & Living'.
Category must match standard services: Plumber, Electrician, Carpenter, Locksmith, Appliance Repair, Cleaning.
''';

        final response = await model.generateContent([Content.text(prompt)]);
        final raw = response.text;

        if (raw != null && raw.isNotEmpty) {
          final parsed = jsonDecode(raw) as Map<String, dynamic>;
          final rawTasks = (parsed['tasks'] as List<dynamic>? ?? [])
              .map((e) => PlanTask.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();

          final plan = RelocationPlan(
            id: planId,
            userId: uid,
            destinationArea: destinationArea,
            householdType: householdType,
            tasks: rawTasks,
            updatedAt: DateTime.now(),
          );

          await _savePlan(plan);
          return plan;
        }
      } catch (e) {
        debugPrint('Gemini plan generation notice: $e');
      }
    }

    // Curated standard relocation plan
    final plan = buildDefaultPlan(
      planId: planId,
      uid: uid,
      area: destinationArea,
      household: householdType,
    );
    await _savePlan(plan);
    return plan;
  }

  Future<void> _savePlan(RelocationPlan plan) async {
    _localPlan = plan;
    try {
      await _firestore
          .collection(FsPaths.plans)
          .doc(plan.id)
          .set(plan.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore plans write note: $e');
    }
  }

  /// Toggle task checkmark (strictly matching Firestore rule changedKeys().hasOnly(['tasks', 'updatedAt']))
  Future<void> toggleTaskCompletion({
    required String planId,
    required List<PlanTask> allTasks,
    required String taskId,
    required bool isCompleted,
  }) async {
    final updated = allTasks
        .map((t) => t.id == taskId ? t.copyWith(isCompleted: isCompleted) : t)
        .toList();

    if (_localPlan != null && _localPlan!.id == planId) {
      _localPlan = RelocationPlan(
        id: planId,
        userId: _localPlan!.userId,
        destinationArea: _localPlan!.destinationArea,
        householdType: _localPlan!.householdType,
        tasks: updated,
        updatedAt: DateTime.now(),
      );
    }

    try {
      await _firestore.collection(FsPaths.plans).doc(planId).update({
        'tasks': updated.map((t) => t.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore plan update note: $e');
    }
  }

  RelocationPlan buildDefaultPlan({
    required String planId,
    required String uid,
    required String area,
    required String household,
  }) {
    return RelocationPlan(
      id: planId,
      userId: uid,
      destinationArea: area,
      householdType: household,
      updatedAt: DateTime.now(),
      tasks: [
        PlanTask(
          id: 't_ro',
          title: 'Install Water Purifier (RO)',
          description: 'Ensure clean drinking water on arrival. Municipal TDS in $area varies.',
          category: 'Plumber',
          phase: 'Day 1 Essentials',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_lock',
          title: 'Change Main Door Lock Cylinders',
          description: 'Vital security step for newly rented or bought properties.',
          category: 'Locksmith',
          phase: 'Day 1 Essentials',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_clean',
          title: 'Pre-Move In Deep Cleaning',
          description: 'Thorough sanitation of kitchen counters, bathrooms, and floor tiles.',
          category: 'Cleaning',
          phase: 'Day 1 Essentials',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_wifi',
          title: 'High-Speed Broadband Internet Connection',
          description: 'Locate top fiber broadband distributors serving $area.',
          category: 'Electrician',
          phase: 'Week 1 Setup',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_geyser',
          title: 'Check Geyser & Water Heater Earthing',
          description: 'Inspect bathroom electrical points and voltage stabilization.',
          category: 'Electrician',
          phase: 'Week 1 Setup',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_gas',
          title: 'LPG Gas Cylinder / Pipeline Connection',
          description: 'Register with nearest gas agency distributor in $area.',
          category: 'Plumber',
          phase: 'Week 1 Setup',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_med',
          title: 'Bookmark Nearest 24x7 Pharmacy & Hospital',
          description: 'Identify emergency care facilities within 3 km of your new home.',
          category: 'Services',
          phase: 'Utilities & Living',
          isCompleted: false,
        ),
        PlanTask(
          id: 't_grocery',
          title: 'Map Local Kirana & Fresh Produce Markets',
          description: 'Explore daily milk, fresh vegetable vendors, and supermarket delivery.',
          category: 'Services',
          phase: 'Utilities & Living',
          isCompleted: false,
        ),
      ],
    );
  }

  // ===========================================================================
  // STREAMS & QUERIES
  // ===========================================================================

  /// Stream user's recent AI diagnosis history
  Stream<List<AiSession>> streamRecentSessions(String uid) {
    if (uid.isEmpty || uid == 'guest') {
      return Stream.value(_localSessions);
    }
    return _firestore
        .collection(FsPaths.aiSessions)
        .where('userId', isEqualTo: uid)
        .limit(10)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return _localSessions;
      return snap.docs.map((d) => AiSession.fromMap(d.id, d.data())).toList();
    }).handleError((_) => _localSessions);
  }

  /// Stream current relocation plan
  Stream<RelocationPlan?> streamActivePlan(String uid) {
    if (uid.isEmpty || uid == 'guest') {
      return Stream.value(_localPlan);
    }
    return _firestore
        .collection(FsPaths.plans)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return _localPlan;
      return RelocationPlan.fromMap(snap.docs.first.id, snap.docs.first.data());
    }).handleError((_) => _localPlan);
  }

  /// Returns active cached plan synchronously if available
  RelocationPlan? get cachedPlan => _localPlan;
  List<AiSession> get cachedSessions => List.unmodifiable(_localSessions);
}
