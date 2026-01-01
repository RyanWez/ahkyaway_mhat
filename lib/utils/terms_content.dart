/// Myanmar Terms and Conditions content.
///
/// Contains all terms text in Myanmar language only.
class TermsContent {
  /// App name for display
  static const String appName = 'AhKyaway Mhat (အကြွေးမှတ်)';

  /// Terms header title
  static const String title = 'စည်းမျဥ်းများနှင့် သတ်မှတ်ချက်များ';

  /// Terms introduction
  static const String introduction =
      'ဤ App ကို အသုံးမပြုမီ အောက်ပါစည်းမျဥ်းများကို သေချာဖတ်ရှုပြီး သဘောတူလက်ခံပါ။';

  /// All terms as a list
  static const List<TermItem> terms = [
    TermItem(
      title: 'ဒေတာသိမ်းဆည်းခြင်း (Data Storage)',
      description:
          'သင့်ဒေတာများသည် သင့်ဖုန်းတွင်သာ အဓိကသိမ်းဆည်းထားပါသည်။ '
          'Cloud Backup မလုပ်ထားပါက App ဖျက်လိုက်လျင် (သို့) ဖုန်းပျက်သွားလျင် '
          'ဒေတာများ ပျောက်ဆုံးသွားနိုင်ပါသည်။',
      icon: '📱',
    ),
    TermItem(
      title: 'ဒေတာလုံခြုံရေး (Security)',
      description:
          'ဒေတာများကို နောက်ဆုံးပေါ်နည်းပညာများသုံး၍ ကုဒ်ထည့်ပြီး (Encrypted) လုံခြုံစွာ သိမ်းဆည်းထားပါသည်။ '
          'သင့်အချက်အလက်များကို ပြင်ပလူများ ဖတ်ရှု၍မရအောင် ကာကွယ်ထားပါသည်။',
      icon: '🔐',
    ),
    TermItem(
      title: 'Cloud Backup',
      description:
          'Google Drive တွင် Backup သိမ်းဆည်းနိုင်ပါသည်။ '
          'သင့် Google Account ၏ လုံခြုံရေးသည် သင့်တာဝန်သာ ဖြစ်ပါသည်။ '
          'မိမိ၏ Google Drive မှလွဲ၍ အခြားမည်သည့်နေရာကမှ သင့်ဒေတာကို ယူဆောင်သွားမည်မဟုတ်ပါ။',
      icon: '☁️',
    ),
    TermItem(
      title: 'ကိုယ်ရေးကိုယ်တာ (Privacy)',
      description:
          'Developer သည် သင့်ငွေစာရင်းများကို ကြည့်ရှုခွင့်မရှိပါ။ '
          'အချက်အလက်များသည် သင့်ဖုန်းနှင့် သင့် Google Drive ကြားတွင်သာ ရှိနေပါမည်။',
      icon: '🛡️',
    ),
    TermItem(
      title: 'တာဝန်ခံမှု (Disclaimer)',
      description:
          'App ကို အသုံးပြုရာတွင် ဖြစ်ပေါ်လာနိုင်သည့် '
          'ငွေကြေးဆိုင်ရာ ပြဿနာများ၊ ဒေတာဆုံးရှုံးမှုများအတွက် '
          'Developer ဘက်မှ တာဝန်ယူမည်မဟုတ်ပါ။ ကိုယ်ပိုင်အကြွေးစာရင်းမှတ်တမ်းအဖြစ်သာ သုံးစွဲပါ။',
      icon: '⚠️',
    ),
    TermItem(
      title: 'တရားဝင်အသုံးပြုမှု',
      description:
          'တရားဝင်မဟုတ်သော ငွေချေးကိစ္စများ (ဥပမာ - တရားမဝင် အတိုးနှုန်းဖြင့် ချေးငှားခြင်း) '
          'အတွက် ဒီ App ကို အသုံးမပြုရပါ။',
      icon: '⚖️',
    ),
  ];

  /// Accept button text
  static const String acceptButtonText = 'လက်ခံပါသည်';

  /// Decline button text
  static const String declineButtonText = 'ပိတ်ပါ';

  /// Decline confirmation message
  static const String declineMessage =
      'စည်းမျဥ်းများကို လက်မခံပါက App ကို ဆက်လက်အသုံးပြု၍ မရပါ။';
}

/// Single term item with title, description and icon.
class TermItem {
  final String title;
  final String description;
  final String icon;

  const TermItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
