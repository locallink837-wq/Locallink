import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language management for English, Hindi, and Marathi.
class AppLanguage {
  AppLanguage._();
  static final AppLanguage instance = AppLanguage._();

  static const _prefKey = 'app_language_code';

  final ValueNotifier<String> currentLanguage = ValueNotifier<String>('en');

  String get code => currentLanguage.value;

  /// Loads saved language preference from local storage on app start.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'en' || saved == 'hi' || saved == 'mr')) {
        currentLanguage.value = saved;
      }
    } catch (_) {}
  }

  void setLanguage(String langCode) {
    if (langCode == 'hi' || langCode == 'mr' || langCode == 'en') {
      currentLanguage.value = langCode;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_prefKey, langCode);
      }).catchError((_) {});
    }
  }

  static String t(String key, {String? defaultText}) {
    final lang = instance.code;
    final dict = _translations[lang];
    if (dict != null && dict.containsKey(key)) {
      return dict[key]!;
    }
    // Fallback to English
    final enDict = _translations['en'];
    if (enDict != null && enDict.containsKey(key)) {
      return enDict[key]!;
    }
    return defaultText ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // General & Common
      'choose_language': 'Choose language',
      'change_later_settings': 'You can change this later in Settings.',
      'continue': 'Continue',
      'save': 'Save',
      'cancel': 'Cancel',
      'next': 'Next',
      'submit': 'Submit',
      'allow': 'Allow',
      'done': 'Done',
      'active': 'Active',
      'cancelled': 'Cancelled',
      'call': 'Call',
      'chat': 'Chat',
      'something_went_wrong': 'Something went wrong. Please try again.',

      // Auth & Role
      'i_am_a': 'I am a',
      'pick_role_desc': 'Pick what describes you best. You can use only one role per account.',
      'customer': 'Customer',
      'customer_hint': 'Find services, places and shops',
      'provider': 'Service provider',
      'provider_hint': 'Get job requests near you',
      'shop_owner': 'Shop owner',
      'shop_owner_hint': 'List your shop',
      'place_owner': 'Place owner',
      'place_owner_hint': 'List your place',
      'sign_in': 'Sign in',
      'sign_up': 'Sign up',
      'create_account': 'Create your account',
      'welcome_back': 'Welcome back',
      'signing_up_as': 'Signing up as',
      'signing_in_as': 'Signing in as',
      'continue_google': 'Continue with Google',
      'or_with_email': 'Or with email',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'dont_have_account': "Don't have an account? Sign up",
      'already_have_account': 'Already have an account? Sign in',
      'phone_number': 'Phone number',
      'send_otp': 'Send OTP',
      'verify_phone': 'Verify phone number',

      // Navigation & Shell
      'nav_home': 'Home',
      'nav_map': 'Map',
      'nav_ai': 'AI Assistant',
      'nav_requests': 'Requests',
      'nav_me': 'Me',
      'nav_dashboard': 'Dashboard',
      'nav_listing': 'Listing',
      'nav_inbox': 'Inbox',
      'nav_wallet': 'Wallet',
      'nav_status': 'Status',
      'nav_edit_info': 'Edit Info',

      // Settings & Profile
      'settings': 'Settings',
      'preferences': 'Preferences',
      'language': 'Language',
      'notifications': 'Notifications',
      'dark_mode': 'Dark mode',
      'account_privacy': 'Account & Privacy',
      'privacy_policy': 'Privacy Policy',
      'log_out': 'Log out',
      'log_out_confirm': 'Are you sure you want to log out?',
      'my_requests': 'My requests',

      // SOS & Emergency
      'sos_title': 'Emergency SOS',
      'sos_call_112': 'Call 112 Helpline',
      'sos_subtitle': 'National All-in-One Emergency',
      'sos_urgent_help': 'Alert urgent service providers',
      'emergency_services_nearby': 'Emergency services nearby',

      // Browse
      'services': 'Services',
      'places': 'Places',
      'shops': 'Shops',
      'nearby': 'Nearby',
      'view_all': 'View all',
      'search_hint': 'Search services, places & shops...',
      'pin_on_map': 'Pin location on map',
      'upload_photo': 'Upload photo',
      'enter_image_url': 'Enter image URL',
    },
    'hi': {
      // General & Common
      'choose_language': 'भाषा चुनें',
      'change_later_settings': 'आप इसे बाद में सेटिंग्स में बदल सकते हैं।',
      'continue': 'आगे बढ़ें',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'next': 'अगला',
      'submit': 'जमा करें',
      'allow': 'अनुमति दें',
      'done': 'पूर्ण',
      'active': 'सक्रिय',
      'cancelled': 'रद्द',
      'call': 'कॉल करें',
      'chat': 'चैट',
      'something_went_wrong': 'कुछ गलत हो गया। कृपया पुन: प्रयास करें।',

      // Auth & Role
      'i_am_a': 'मैं हूँ',
      'pick_role_desc': 'जो आपके लिए सबसे उपयुक्त हो उसे चुनें। आप प्रति खाते केवल एक भूमिका का उपयोग कर सकते हैं।',
      'customer': 'ग्राहक',
      'customer_hint': 'सेवाएं, स्थान और दुकानें खोजें',
      'provider': 'सेवा प्रदाता',
      'provider_hint': 'अपने आस-पास काम के अनुरोध प्राप्त करें',
      'shop_owner': 'दुकानदार',
      'shop_owner_hint': 'अपनी दुकान सूचीबद्ध करें',
      'place_owner': 'स्थान संचालक',
      'place_owner_hint': 'अपना स्थान (अस्पताल, कॉलेज आदि) सूचीबद्ध करें',
      'sign_in': 'साइन इन करें',
      'sign_up': 'साइन अप करें',
      'create_account': 'अपना खाता बनाएं',
      'welcome_back': 'वापसी पर स्वागत है',
      'signing_up_as': 'साइन अप कर रहे हैं:',
      'signing_in_as': 'साइन इन कर रहे हैं:',
      'continue_google': 'Google के साथ आगे बढ़ें',
      'or_with_email': 'या ईमेल द्वारा',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'dont_have_account': 'खाता नहीं है? साइन अप करें',
      'already_have_account': 'पहले से खाता है? साइन इन करें',
      'phone_number': 'फ़ोन नंबर',
      'send_otp': 'ओटीपी भेजें',
      'verify_phone': 'फ़ोन नंबर सत्यापित करें',

      // Navigation & Shell
      'nav_home': 'होम',
      'nav_map': 'नक्शा',
      'nav_ai': 'एआई सहायक',
      'nav_requests': 'अनुरोध',
      'nav_me': 'प्रोफ़ाइल',
      'nav_dashboard': 'डैशबोर्ड',
      'nav_listing': 'लिस्टिंग',
      'nav_inbox': 'इनबॉक्स',
      'nav_wallet': 'वॉलेट',
      'nav_status': 'स्थिति',
      'nav_edit_info': 'जानकारी बदलें',

      // Settings & Profile
      'settings': 'सेटिंग्स',
      'preferences': 'प्राथमिकताएं',
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'dark_mode': 'डार्क मोड',
      'account_privacy': 'खाता और गोपनीयता',
      'privacy_policy': 'गोपनीयता नीति',
      'log_out': 'लॉग आउट',
      'log_out_confirm': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
      'my_requests': 'मेरे अनुरोध',

      // SOS & Emergency
      'sos_title': 'आपातकालीन एसओएस',
      'sos_call_112': '112 हेल्पलाइन पर कॉल करें',
      'sos_subtitle': 'राष्ट्रीय आपातकालीन सेवा',
      'sos_urgent_help': 'तत्काल सेवा प्रदाताओं को सूचित करें',
      'emergency_services_nearby': 'निकटतम आपातकालीन सेवाएं',

      // Browse
      'services': 'सेवाएं',
      'places': 'स्थान',
      'shops': 'दुकानें',
      'nearby': 'आस-पास',
      'view_all': 'सभी देखें',
      'search_hint': 'सेवाएं, स्थान और दुकानें खोजें...',
      'pin_on_map': 'नक्शे पर स्थान चुनें',
      'upload_photo': 'फोटो अपलोड करें',
      'enter_image_url': 'फोटो का URL दर्ज करें',
    },
    'mr': {
      // General & Common
      'choose_language': 'भाषा निवडा',
      'change_later_settings': 'तुम्ही हे नंतर सेटिंग्जमध्ये बदलू शकता.',
      'continue': 'पुढे जा',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'next': 'पुढे',
      'submit': 'सबमिट करा',
      'allow': 'परवानगी द्या',
      'done': 'पूर्ण झाले',
      'active': 'सक्रिय',
      'cancelled': 'रद्द केलेल्या',
      'call': 'कॉल करा',
      'chat': 'चॅट करा',
      'something_went_wrong': 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.',

      // Auth & Role
      'i_am_a': 'मी आहे',
      'pick_role_desc': 'तुमच्यासाठी सर्वात योग्य पर्याय निवडा. एका खात्यासाठी फक्त एकच भूमिका वापरता येईल.',
      'customer': 'ग्राहक',
      'customer_hint': 'सेवा, महत्त्वाची ठिकाणे व दुकाने शोधा',
      'provider': 'सेवा प्रदाता',
      'provider_hint': 'तुमच्या जवळ कामाच्या विनंत्या मिळवा',
      'shop_owner': 'दुकानदार',
      'shop_owner_hint': 'तुमचे दुकान नोंदवा',
      'place_owner': 'ठिकाण संचालक',
      'place_owner_hint': 'तुमचे ठिकाण (रुग्णालय, कॉलेज इ.) नोंदवा',
      'sign_in': 'साइन इन करा',
      'sign_up': 'साइन अप करा',
      'create_account': 'तुमचे खाते तयार करा',
      'welcome_back': 'पुन्हा स्वागत आहे',
      'signing_up_as': 'या भूमिकेत साइन अप करत आहात:',
      'signing_in_as': 'या भूमिकेत साइन इन करत आहात:',
      'continue_google': 'Google सह पुढे जा',
      'or_with_email': 'किंवा ईमेलद्वारे',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड विसरलात?',
      'dont_have_account': 'खाते नाही? साइन अप करा',
      'already_have_account': 'आधीच खाते आहे? साइन इन करा',
      'phone_number': 'फोन नंबर',
      'send_otp': 'OTP पाठवा',
      'verify_phone': 'फोन नंबर पडताळणी करा',

      // Navigation & Shell
      'nav_home': 'मुख्यपृष्ठ',
      'nav_map': 'नकाशा',
      'nav_ai': 'एआय मदतनीस',
      'nav_requests': 'विनंत्या',
      'nav_me': 'माझे खाते',
      'nav_dashboard': 'डॅशबोर्ड',
      'nav_listing': 'लिस्टिंग',
      'nav_inbox': 'इनबॉक्स',
      'nav_wallet': 'वॉलेट',
      'nav_status': 'स्थिती',
      'nav_edit_info': 'माहिती बदला',

      // Settings & Profile
      'settings': 'सेटिंग्ज',
      'preferences': 'पसंती',
      'language': 'भाषा',
      'notifications': 'सूचना (Notifications)',
      'dark_mode': 'डार्क मोड (Dark Mode)',
      'account_privacy': 'खाते आणि गोपनीयता',
      'privacy_policy': 'गोपनीयता धोरण',
      'log_out': 'लॉग आउट (Log Out)',
      'log_out_confirm': 'तुम्हाला नक्की लॉग आउट करायचे आहे का?',
      'my_requests': 'माझ्या विनंत्या',

      // SOS & Emergency
      'sos_title': 'आपत्कालीन SOS',
      'sos_call_112': '112 हेल्पलाईन कॉल करा',
      'sos_subtitle': 'राष्ट्रीय आपत्कालीन सेवा',
      'sos_urgent_help': 'तातडीच्या सेवा प्रदात्यांना कळवा',
      'emergency_services_nearby': 'जवळपासच्या आपत्कालीन सेवा',

      // Browse
      'services': 'सेवा',
      'places': 'महत्त्वाची ठिकाणे',
      'shops': 'दुकाने',
      'nearby': 'जवळपास',
      'view_all': 'सर्व पहा',
      'search_hint': 'सेवा, ठिकाणे व दुकाने शोधा...',
      'pin_on_map': 'नकाशावर जागा निवडा',
      'upload_photo': 'फोटो अपलोड करा',
      'enter_image_url': 'फोटो URL टाका',
    },
  };
}

extension AppLanguageExtension on BuildContext {
  String tr(String key, {String? defaultText}) =>
      AppLanguage.t(key, defaultText: defaultText);
}
