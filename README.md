<div align="center">

# 💰 AhKyaway Mhat (အကြွေးမှတ်)

<img src="assets/icons/app_icon.png" alt="AhKyaway Mhat Logo" width="120" height="120">

### 🏪 Smart Debt Tracking App for Small Businesses & Communities

<p>
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.10.1+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Version-2.0.9-green?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License">
</p>

<p>
  <img src="https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android" alt="Platform">
</p>

---

<p><strong>AhKyaway Mhat</strong> (အကြွေးမှတ်) is a modern, secure, and user-friendly debt tracking application designed specifically for the Myanmar market. Perfect for small shopkeepers, community lending groups, and individuals who need to manage credits and debts efficiently.</p>

</div>

---

## ✨ Features (လုပ်ဆောင်ချက်များ)

<table>
  <tr>
    <td width="50%">
      <h3>☁️ Cloud Backup & Restore</h3>
      <ul>
        <li><strong>Google Drive Integration</strong>: Securely backup your data to your personal Google Drive.</li>
        <li><strong>Restore Anywhere</strong>: Easily restore your data on a new device.</li>
        <li><strong>Privacy First</strong>: Your data stays between your device and your cloud.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🔐 Enhanced Security</h3>
      <ul>
        <li><strong>Encrypted Storage</strong>: All local data is encrypted using military-grade security (AES).</li>
        <li><strong>Secure Data Migration</strong>: Auto-encryption for legacy data.</li>
        <li><strong>Privacy Focused</strong>: No unauthorized tracking or data collection.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📊 Dashboard & Analytics</h3>
      <ul>
        <li>Real-time overview of total outstanding debts.</li>
        <li>Active vs completed debt statistics.</li>
        <li>Visual progress indicators and summary widgets.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>👥 Customer Management</h3>
      <ul>
        <li>Add, edit, and delete customers effortlessly.</li>
        <li>Store contact info (phone with direct call support).</li>
        <li>View complete debt history per customer.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>💳 Comprehensive Tracking</h3>
      <ul>
        <li>Track Principal amounts with due dates.</li>
        <li><strong>Partial Payments</strong>: Record installment payments easily.</li>
        <li>Auto-status updates (Active/Completed).</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🌍 Localization</h3>
      <ul>
        <li><strong>Myanmar Language (Unicode)</strong>: Native support with custom fonts (PangramBig).</li>
        <li>English language support available.</li>
        <li>Easy language switching within the app.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🌙 Modern UI/UX</h3>
      <ul>
        <li>Beautiful Glassmorphism design.</li>
        <li><strong>Dark & Light Modes</strong>: Auto-adapts to system settings or manual toggle.</li>
        <li>Smooth Lottie animations and haptic feedback.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🔄 Smart Updates</h3>
      <ul>
        <li><strong>Auto-Update</strong>: Checks for new versions automatically (Android).</li>
        <li>Seamless In-App Update experience.</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🏗️ Technical Stack

This project is built using modern Flutter development standards.

| Category | Technology | Purpose |
|----------|------------|---------|
| **Core** | Flutter & Dart | Cross-platform development |
| **State Management** | `provider` | Efficient & scalable state management |
| **Storage** | `flutter_secure_storage` | **Encrypted** local data persistence |
| **Cloud** | `google_sign_in` & `googleapis` | Google Drive API integration |
| **Localization** | `easy_localization` | Internationalization support |
| **Styling** | `google_fonts` & `lottie` | Custom typography and animations |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `3.10.0` or higher
- Android SDK (min SDK 21)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/RyanWez/ahkyaway_mhat.git
    cd ahkyaway_mhat
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    flutter run
    ```

### Building for Release (Android)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚠️ Important Notes

*   **Encryption**: Since Version 2.0.0, all data is encrypted. If upgrading from a very old version, data migration happens automatically on first launch.
*   **Google Drive**: Requires a Google Account to use backup features. The API uses `drive.appdata` scope, meaning it only accesses files created by this app, ensuring your other Drive files remain private.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

### Made with ❤️ in Myanmar

<p>
  <a href="https://github.com/RyanWez/ahkyaway_mhat-releases/releases">
    <img src="https://img.shields.io/badge/Download-Latest%20APK-success?style=for-the-badge&logo=android&logoColor=white" alt="Download">
  </a>
</p>

**⭐ Star this repo if you find it useful!**

</div>
