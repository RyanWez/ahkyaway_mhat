<div align="center">

# 💰 AhKyaway Mhat

<img src="assets/icons/app_icon.png" alt="AhKyaway Mhat Logo" width="120" height="120">

### 🏪 Debt Tracking App for Small Businesses & Communities

<p>
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.10.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Version-2.0.6-green?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License">
</p>

<p>
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Windows%20|%20macOS%20|%20Linux%20|%20Web-blue?style=flat-square" alt="Platform">
</p>

---

<p><strong>AhKyaway Mhat</strong> (အကြွေးမှတ်) is a beautifully designed, cross-platform debt tracking application built with Flutter, perfect for small shopkeepers, community lending groups, and anyone who needs to manage debts efficiently.</p>

</div>

---

## ✨ Features

<table>
  <tr>
    <td width="50%">
      <h3>📊 Dashboard & Analytics</h3>
      <ul>
        <li>Real-time overview of total outstanding debts</li>
        <li>Active vs completed debt statistics</li>
        <li>Quick summary widgets for at-a-glance info</li>
        <li>Visual progress indicators</li>
      </ul>
    </td>
    <td width="50%">
      <h3>👥 Customer Management</h3>
      <ul>
        <li>Add, edit, and delete customers</li>
        <li>Store contact info (phone, address)</li>
        <li>Add notes for each customer</li>
        <li>View customer debt history</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>💳 Debt Tracking</h3>
      <ul>
        <li>Create debts with principal amount</li>
        <li>Set start date and due date</li>
        <li>Track debt status (active/completed)</li>
        <li>Add notes for each debt record</li>
      </ul>
    </td>
    <td width="50%">
      <h3>💵 Payment Management</h3>
      <ul>
        <li>Record partial or full payments</li>
        <li>View payment history per debt</li>
        <li>Auto-calculate remaining balance</li>
        <li>Delete payments with auto debt status update</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🌙 Theme & UI</h3>
      <ul>
        <li>Modern glassmorphism design</li>
        <li>Dark & Light theme modes</li>
        <li>Smooth Lottie animations</li>
        <li>Floating navigation bar with haptic feedback</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🌐 Localization</h3>
      <ul>
        <li>English language support</li>
        <li>Myanmar (Burmese) language support</li>
        <li>Custom Myanmar font (PangramBig)</li>
        <li>Easy language switching</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔄 Auto Updates</h3>
      <ul>
        <li>GitHub Releases integration</li>
        <li>Automatic version checking</li>
        <li>Device-specific APK detection (arm64, armeabi, x86)</li>
        <li>Beautiful update dialog with release notes</li>
      </ul>
    </td>
    <td width="50%">
      <h3>📱 Cross-Platform</h3>
      <ul>
        <li>Android (APK available)</li>
        <li>iOS</li>
        <li>Windows Desktop</li>
        <li>macOS, Linux, Web</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🏗️ Architecture & Tech Stack

<table>
  <tr>
    <th>Category</th>
    <th>Technology</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td><strong>Framework</strong></td>
    <td>Flutter 3.10+</td>
    <td>Cross-platform UI development</td>
  </tr>
  <tr>
    <td><strong>Language</strong></td>
    <td>Dart 3.10.1+</td>
    <td>Programming language</td>
  </tr>
  <tr>
    <td><strong>State Management</strong></td>
    <td>Provider 6.1.2</td>
    <td>Reactive state management</td>
  </tr>
  <tr>
    <td><strong>Local Storage</strong></td>
    <td>SharedPreferences</td>
    <td>Persistent data storage</td>
  </tr>
  <tr>
    <td><strong>Localization</strong></td>
    <td>easy_localization</td>
    <td>Multi-language support</td>
  </tr>
  <tr>
    <td><strong>Fonts</strong></td>
    <td>google_fonts</td>
    <td>Typography & Myanmar font</td>
  </tr>
  <tr>
    <td><strong>Animations</strong></td>
    <td>Lottie, dotlottie_loader</td>
    <td>Smooth UI animations</td>
  </tr>
  <tr>
    <td><strong>Networking</strong></td>
    <td>http, connectivity_plus</td>
    <td>API calls & network monitoring</td>
  </tr>
  <tr>
    <td><strong>Desktop</strong></td>
    <td>window_manager</td>
    <td>Desktop window controls</td>
  </tr>
  <tr>
    <td><strong>Updates</strong></td>
    <td>package_info_plus, url_launcher</td>
    <td>Version checking & update downloads</td>
  </tr>
</table>

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point with splash screen
├── models/
│   ├── customer.dart      # Customer data model
│   ├── debt.dart          # Debt data model with status
│   └── payment.dart       # Payment data model
├── providers/
│   └── theme_provider.dart # Theme state management
├── screens/
│   ├── home_screen.dart   # Main navigation screen
│   ├── splash_screen.dart # Animated splash screen
│   ├── dashboard/         # Dashboard & statistics
│   ├── customer/          # Customer CRUD screens
│   ├── debt/              # Debt management screens
│   ├── settings/          # App settings
│   └── account/           # Account/profile screen
├── services/
│   ├── storage_service.dart      # Local data persistence
│   ├── github_update_service.dart # Auto-update checker
│   └── connectivity_service.dart  # Network status
├── theme/
│   └── app_theme.dart     # Dark/Light theme definitions
├── utils/
│   ├── app_localization.dart # Locale settings
│   └── responsive.dart       # Responsive utilities
└── widgets/               # Reusable UI components
```

---

## ⚠️ Limitations & Known Issues

<table>
  <tr>
    <th>⚡ Limitation</th>
    <th>📝 Description</th>
  </tr>
  <tr>
    <td><strong>Local Storage Only</strong></td>
    <td>Data is stored locally using SharedPreferences. No cloud sync or backup feature available. Data will be lost if app is uninstalled.</td>
  </tr>
  <tr>
    <td><strong>No Encryption</strong></td>
    <td>Data is stored in plain JSON format without encryption. Not suitable for highly sensitive financial data.</td>
  </tr>
  <tr>
    <td><strong>No Interest Calculation</strong></td>
    <td>The app tracks principal amounts only. Automatic interest calculation is not supported.</td>
  </tr>
  <tr>
    <td><strong>Single User</strong></td>
    <td>No multi-user or authentication system. Only one user's data per device.</td>
  </tr>
  <tr>
    <td><strong>No Export/Import</strong></td>
    <td>No feature to export data to CSV/Excel or import from backup files.</td>
  </tr>
  <tr>
    <td><strong>No Payment Reminders</strong></td>
    <td>No push notifications or reminders for due dates.</td>
  </tr>
  <tr>
    <td><strong>Internet Required for Updates</strong></td>
    <td>Auto-update checking requires internet connection.</td>
  </tr>
  <tr>
    <td><strong>Android APK Updates Only</strong></td>
    <td>Auto-update feature with direct download only works for Android APK releases.</td>
  </tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.10.1 or higher

### Installation

```bash
# Clone the repository
git clone https://github.com/RyanWez/ahkyaway_mhat.git

# Navigate to project directory
cd ahkyaway_mhat

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

---

## 📱 Screenshots

<div align="center">
  <p><em>Coming Soon...</em></p>
</div>

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

### Made with ❤️ using Flutter

<p>
  <a href="https://github.com/RyanWez/ahkyaway_mhat/releases">
    <img src="https://img.shields.io/badge/Download-Latest%20Release-success?style=for-the-badge&logo=github" alt="Download">
  </a>
</p>

**⭐ Star this repo if you find it useful!**

</div>
