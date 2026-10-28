import 'package:flutter/material.dart';

/// App language management for English, Hindi, and Marathi.
class AppLanguage {
  AppLanguage._();
  static final AppLanguage instance = AppLanguage._();

  final ValueNotifier<String> currentLanguage = ValueNotifier<String>('en');

  String get code => currentLanguage.value;

  void setLanguage(String langCode) {
    if (langCode == 'hi' || langCode == 'mr' || langCode == 'en') {
      currentLanguage.value = langCode;
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

      'settings': 'Settings',
      'preferences': 'Preferences',
      'language': 'Language',
      'notifications': 'Notifications',
      'dark_mode': 'Dark mode',
      'account_privacy': 'Account & Privacy',
      'privacy_policy': 'Privacy Policy',
      'log_out': 'Log out',
      'log_out_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'save': 'Save',
      'next': 'Next',
      'submit': 'Submit',
      'allow': 'Allow',
      'call': 'Call',
      'chat': 'Chat',
      'done': 'Done',
      'active': 'Active',
      'cancelled': 'Cancelled',
      'my_requests': 'My requests',

      'sos_title': 'Emergency SOS',
      'sos_call_112': 'Call 112 Helpline',
      'sos_subtitle': 'National All-in-One Emergency',
      'sos_urgent_help': 'Alert urgent service providers',
      'emergency_services_nearby': 'Emergency services nearby',

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

      'settings': 'सेटिंग्स',
      'preferences': 'प्राथमिकताएं',
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'dark_mode': 'डार्क मोड',
      'account_privacy': 'खाता और गोपनीयता',
      'privacy_policy': 'गोपनीयता नीति',
      'log_out': 'लॉग आउट',
      'log_out_confirm': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
      'cancel': 'रद्द करें',
      'continue': 'आगे बढ़ें',
      'save': 'सहेजें',
      'next': 'अगला',
      'submit': 'जमा करें',
      'allow': 'अनुमति दें',
      'call': 'कॉल करें',
      'chat': 'चैट',
      'done': 'पूर्ण',
      'active': 'सक्रिय',
      'cancelled': 'रद्द',
      'my_requests': 'मेरे अनुरोध',

      'sos_title': 'आपातकालीन एसओएस',
      'sos_call_112': '112 हेल्पलाइन पर कॉल करें',
      'sos_subtitle': 'राष्ट्रीय आपातकालीन सेवा',
      'sos_urgent_help': 'तत्काल सेवा प्रदाताओं को सूचित करें',
      'emergency_services_nearby': 'निकटतम आपातकालीन सेवाएं',

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

      'settings': 'सेटिंग्ज',
      'preferences': 'पसंती',
      'language': 'भाषा',
      'notifications': 'सूचना (Notifications)',
      'dark_mode': 'डार्क मोड (Dark Mode)',
      'account_privacy': 'खाते आणि गोपनीयता',
      'privacy_policy': 'गोपनीयता धोरण',
      'log_out': 'लॉग आउट (Log Out)',
      'log_out_confirm': 'तुम्हाला नक्की लॉग आउट करायचे आहे का?',
      'cancel': 'रद्द करा',
      'continue': 'पुढे जा',
      'save': 'जतन करा',
      'next': 'पुढे',
      'submit': 'सबमिट करा',
      'allow': 'परवानगी द्या',
      'call': 'कॉल करा',
      'chat': 'चॅट करा',
      'done': 'पूर्ण झाले',
      'active': 'सक्रिय',
      'cancelled': 'रद्द केलेल्या',
      'my_requests': 'माझ्या विनंत्या',

      'sos_title': 'आपत्कालीन SOS',
      'sos_call_112': '112 हेल्पलाईन कॉल करा',
      'sos_subtitle': 'राष्ट्रीय आपत्कालीन सेवा',
      'sos_urgent_help': 'तातडीच्या सेवा प्रदात्यांना कळवा',
      'emergency_services_nearby': 'जवळपासच्या आपत्कालीन सेवा',

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
