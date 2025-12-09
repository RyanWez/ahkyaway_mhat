# 💰 AhKyaway Mhat App

A refined and modern Flutter application for managing customer loans and payments. Designed with a premium "Glassmorphism" aesthetic, it supports both English and Myanmar languages.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Key Features

### 🌍 Multi-Language Support

- Full support for **English** and **Myanmar** languages.
- Seamless language switching within the app settings.
- Proper font rendering for Myanmar text using Google Fonts.

### 📊 Interactive Dashboard

- Real-time overview of active and completed loans.
- Beautiful animated charts visualizing loan distribution.
- **Sticky Headers**: Advanced collapsing headers that adapt as you scroll for a premium feel.

### 👥 Customer Management

- **Smart Search**: Quickly find customers by name.
- Detailed customer profiles with borrowing history.
- Validation for inputs (Phone numbers, Names) to ensure data integrity.
- **Safety**: Prevents deletion of customers with active loans to avoid data loss.

### 💳 Loan & Payment Tracking

- Create, manage, and track loans with ease.
- Visual progress bars for repayment status.
- **Payment History**: Detailed record of every payment made.
- Currency formatting tailored for easy reading (e.g., 1,000,000).

### 🎨 Modern UI/UX

- **Glassmorphism Design**: Sleek, modern interface with blur effects and gradients.
- **Dark/Light Theme**: Fully supported system-aware theming.
- **Smooth Animations**: Transitions and micro-interactions for a polished experience.

## 🛠️ Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State Management |
| `shared_preferences` | Local Data Persistence (Offline support) |
| `easy_localization` | Internationalization (i18n) |
| `google_fonts` | Custom Typography |
| `intl` | Currency & Date Formatting |
| `package_info_plus` | App Version Display |
| `url_launcher` | External Interaction (Phone/SMS) |



## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK 3.0 or higher

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/RyanWez/loan_tracking.git
   cd loan_tracking
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**

   ```bash
   flutter run
   ```

## 🔧 Configuration

**Storage**: The app uses `shared_preferences` to store all data locally on the device in JSON format. Uninstalling the app *will* clear this data as no remote database is used.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ using Flutter
