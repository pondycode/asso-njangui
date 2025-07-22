# 📱 Association Management App (Asso Njangui)

A comprehensive Flutter application for managing association finances, members, loans, and contributions. Built specifically for community associations and savings groups.

## 🌟 Features

### 👥 Member Management
- Complete member profiles with contact information
- Member status tracking (Active, Inactive, Suspended)
- Financial summary for each member
- Contribution and loan history

### 💰 Fund Management
- Multiple fund types (Savings, Investment, Emergency, Custom)
- Real-time balance tracking
- Interest rate calculations
- Fund transaction history

### 🧾 Contribution Management
- Easy contribution recording
- Multiple fund allocation
- Duplicate detection
- Search and filter capabilities
- Automated calculations

### 💳 Loan Management
- Month-by-month interest accumulation system
- Fixed monthly interest (3,150 CFA per month)
- Payment tracking with principal-first allocation
- Loan application and approval workflow
- Balance calculations and payment schedules

### ⚖️ Penalty Management
- Multiple penalty types (Late fees, Missed contributions, etc.)
- Automated penalty calculations
- Penalty rules and enforcement
- Status tracking (Pending, Active, Paid, Waived)

### 🧾 Transaction Management
- Complete transaction history
- Multiple transaction types
- Search and filter functionality
- Export capabilities

### 🌐 Multi-language Support
- French and English language support
- Easy language switching
- Localized currency formatting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/asso_njangui.git
   cd asso_njangui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code files**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **Models**: Data structures with Hive annotations for local storage
- **Services**: Business logic and data operations
- **Providers**: State management using Provider pattern
- **Screens**: UI components organized by feature
- **Utils**: Helper functions and utilities

### Key Dependencies

- **hive**: Local database storage
- **provider**: State management
- **intl**: Internationalization
- **uuid**: Unique identifier generation
- **equatable**: Value equality

## 📊 Data Storage

The app uses Hive for local data storage, ensuring:
- Fast performance
- Offline functionality
- Data persistence
- Type-safe operations

## 🔧 Configuration

### Contribution Settings
Configure default values for faster data entry:
- Default dates
- Default host selection
- Auto-fill preferences

### Language Settings
Switch between French and English:
- Tap the language icon (🌐) in the dashboard
- Select preferred language from dropdown

## 📖 User Guide

For detailed usage instructions, see [USER_GUIDE.md](USER_GUIDE.md) which covers:
- Dashboard overview
- Member management
- Fund operations
- Loan processing
- Penalty management
- Settings configuration

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 🏗️ Building

### Android APK
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## 📁 Project Structure

```
lib/
├── l10n/                 # Localization files
├── models/               # Data models
├── providers/            # State management
├── screens/              # UI screens
│   ├── contributions/    # Contribution management
│   ├── funds/           # Fund management
│   ├── loans/           # Loan management
│   ├── members/         # Member management
│   ├── penalties/       # Penalty management
│   ├── settings/        # App settings
│   └── transactions/    # Transaction management
├── services/            # Business logic
└── utils/               # Helper utilities
```

## 💡 Key Features Explained

### Loan Interest System
The app implements a unique month-by-month interest accumulation system:
- **Fixed Monthly Rate**: 3,150 CFA per month
- **Simple Interest**: No compounding
- **Payment Priority**: Principal first, then interest
- **Example**: 31,500 CFA loan after 10.8 months = 23,500 principal + 34,020 interest = 57,520 total

### Smart Contribution Management
- **Duplicate Detection**: Prevents same-day duplicate entries
- **Default Settings**: Speed up data entry with pre-configured defaults
- **Search & Filter**: Find contributions by member, fund, date, or amount
- **Real-time Totals**: Automatic calculation of filtered results

### Comprehensive Penalty System
- **Multiple Types**: Late fees, missed contributions, loan defaults, etc.
- **Flexible Calculations**: Fixed amount, percentage, daily rate, or tiered
- **Automated Rules**: Set up automatic penalty application
- **Status Tracking**: Monitor penalty lifecycle from application to payment

## 🔒 Security & Privacy

- **Local Storage**: All data stored securely on device
- **No Cloud Dependency**: Works completely offline
- **Data Control**: Users control all data exports and backups
- **Privacy First**: No personal data transmitted externally

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check [USER_GUIDE.md](USER_GUIDE.md) for detailed instructions
- **Issues**: Report bugs or request features via GitHub Issues
- **Discussions**: Join community discussions for tips and best practices

## 🙏 Acknowledgments

- Built with Flutter framework
- Uses Hive for efficient local storage
- Inspired by community association management needs
- Designed for simplicity and reliability

## 📈 Roadmap

### Upcoming Features
- [ ] Cloud synchronization
- [ ] Advanced reporting and analytics
- [ ] Mobile notifications
- [ ] Multi-currency support
- [ ] API integration capabilities
- [ ] Batch operations
- [ ] Enhanced security features

### Version History
- **v1.0.0**: Initial release with core features
  - Member management
  - Fund operations
  - Loan processing
  - Contribution tracking
  - Penalty management
  - Multi-language support

---

**Made with ❤️ for community associations and savings groups**

For detailed usage instructions and examples, please refer to the [Complete User Guide](USER_GUIDE.md).
