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
      title: 'ဒေတာသိမ်းဆည်းခြင်း',
      description: 
          'သင့်ဒေတာအားလုံးသည် သင့်ဖုန်းတွင်သာ သိမ်းဆည်းထားပါသည်။ '
          'App ကို ဖျက်လိုက်ပါက သို့မဟုတ် ဖုန်း data များ ပျက်သွားပါက '
          'ဒေတာများ အကုန်ပျောက်သွားပါမည်။',
      icon: '📱',
    ),
    TermItem(
      title: 'ဒေတာလုံခြုံရေး',
      description: 
          'ဒေတာများကို ကုဒ်ထည့်ပြီး (encrypt) မသိမ်းဆည်းထားပါ။ '
          'ထို့ကြောင့် အလွန်အရေးကြီးသော ငွေကြေးဆိုင်ရာ အချက်အလက်များ '
          'သိမ်းရန် မသင့်လျော်ပါ။',
      icon: '🔓',
    ),
    TermItem(
      title: 'တာဝန်ခံမှု',
      description: 
          'ဒီ App ကို အသုံးပြုရာတွင် ဖြစ်ပေါ်လာနိုင်သည့် '
          'ငွေကြေးဆိုင်ရာ ပြဿနာများ၊ ဒေတာဆုံးရှုံးမှုများအတွက် '
          'Developer က တာဝန်မယူပါ။ ကိုယ်ပိုင်စာရင်းမှတ်တမ်းအဖြစ်သာ အသုံးပြုပါ။',
      icon: '⚠️',
    ),
    TermItem(
      title: 'ကိုယ်ရေးကိုယ်တာ',
      description: 
          'App သည် သင့်ဖုန်းအပြင်ဘက်သို့ ဒေတာမပို့ပါ။ '
          'Internet သုံးရတာက App update စစ်ဆေးခြင်းအတွက်သာ ဖြစ်ပါသည်။',
      icon: '🔐',
    ),
    TermItem(
      title: 'တစ်ဦးတည်းအသုံးပြုမှု',
      description: 
          'ဒီ App ကို ဖုန်းတစ်လုံးမှာ တစ်ယောက်တည်းသာ အသုံးပြုနိုင်ပါသည်။ '
          'Multi-user စနစ် မရှိပါ။',
      icon: '👤',
    ),
    TermItem(
      title: 'တရားဝင်အသုံးပြုမှု',
      description: 
          'တရားဝင်မဟုတ်သော ငွေချေးကိစ္စများ (ဥပမာ - တရားမဝင် အတိုးနှုန်းဖြင့် ချေးငှားခြင်း) '
          'အတွက် ဒီ App ကို အသုံးမပြုရပါ။',
      icon: '⚖️',
    ),
    TermItem(
      title: 'Cloud Backup',
      description: 
          'Cloud Backup နှင့် Sync လုပ်ဆောင်ချက်များကို မကြာမှီ ထည့်သွင်းပေးသွားပါမည်။ '
          'လောလောဆယ် သင့်ဒေတာသည် ဖုန်းတွင်သာ ရှိပါသည်။',
      icon: '☁️',
    ),
    TermItem(
      title: 'App Updates',
      description: 
          'App updates များကို စစ်ဆေးရန် Internet ချိတ်ဆက်မှု လိုအပ်ပါသည်။ '
          'အသစ်ထွက်ရှိသော version များရှိပါက အကြောင်းကြားပါမည်။',
      icon: '🔄',
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
