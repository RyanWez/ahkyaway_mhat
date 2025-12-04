# 💰 Loan Tracking App

A beautiful and modern Flutter application for managing customer loans and payments. Track debts, record payments, and monitor loan statuses with an intuitive user interface.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 📊 Dashboard

- Overview of total loans, active loans, and completed loans
- Beautiful animated circular chart showing loan distribution
- Quick stats with real-time updates

### 👥 Customer Management

- Add, edit, and delete customers
- View customer details with their loan history
- Search and filter customers
- Character limits for input fields (Name: 32, Phone: 11, Address/Notes: 50)

### 💳 Loan Management

- Create new loans for customers
- Track loan amounts with comma-formatted currency display
- View loan progress with visual progress bars
- Payment history tracking
- Auto-complete loans when fully paid

### 💵 Payment Tracking

- Record payments against loans
- Date picker for payment dates
- Notes support for each payment
- Swipe to delete payments

### 🔒 Smart Restrictions

- Cannot delete customers with active loans
- Cannot delete loans until fully repaid
- Auto status update: ACTIVE → COMPLETED when loan is paid off

### 🎨 UI/UX

- Dark and Light theme support
- Modern glassmorphism design
- Smooth animations and transitions
- Currency formatting with comma separators (1,000,000)
- Responsive layout

## 🛠️ Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Local data persistence |
| `intl` | Date and number formatting |
| `uuid` | Unique ID generation |

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── customer.dart      # Customer data model
│   ├── loan.dart          # Loan data model
│   └── payment.dart       # Payment data model
├── providers/
│   └── theme_provider.dart # Theme state management
├── screens/
│   ├── dashboard_screen.dart    # Main dashboard
│   ├── customers_screen.dart    # Customer list
│   ├── customer_detail_screen.dart # Customer details
│   └── loan_detail_screen.dart  # Loan details
├── services/
│   └── storage_service.dart     # Data persistence
├── theme/
│   └── app_theme.dart           # App theming
├── utils/
│   └── currency_input_formatter.dart # Currency formatting
└── widgets/
    └── animated_circular_chart.dart  # Animated chart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK 3.0 or higher

### Installation

1. Clone the repository:

```bash
git clone https://github.com/RyanWez/loan_tracking.git
cd loan_tracking
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## 📱 Screenshots

| Dashboard | Customers | Loan Details |
|-----------|-----------|--------------|
| Overview stats | Customer list | Payment progress |

## 🔧 Configuration

The app uses local storage (SharedPreferences) for data persistence. No external database or backend required.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

Made with ❤️ using Flutter
