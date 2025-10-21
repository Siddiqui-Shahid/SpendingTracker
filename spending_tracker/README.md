# 💰 Spending Tracker (Spendz)

A modern, secure Flutter application for tracking personal finances with biometric authentication, expense management, and insightful financial overview.

## 📋 Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Architecture](#architecture)
- [Dependencies](#dependencies)
- [Build & Deployment](#build--deployment)
- [Contributing](#contributing)

## ✨ Features

### Core Features
- **Expense Tracking**: Record, categorize, and manage income and expense transactions
- **Balance Management**: Real-time balance calculation and tracking
- **Transaction History**: Comprehensive history of all financial transactions
- **Edit & Delete**: Modify or remove transactions as needed

### Security
- **Biometric Authentication**: Secure fingerprint/face recognition authentication
- **App Lock**: Protect sensitive financial data with local authentication
- **Settings Customization**: Enable/disable biometric security as needed

### User Experience
- **Intuitive Dashboard**: Clean home screen displaying current balance and recent transactions
- **Transaction Management**: Easy-to-use interface for adding and managing transactions
- **Balance Overview**: Visual representation of financial overview
- **Settings Panel**: Comprehensive app settings and configuration options

### Data Management
- **Local Storage**: Hive-based persistent data storage
- **No Cloud Dependencies**: All data stored locally on device
- **Data Export**: Export transaction history to files
- **Data Reset**: Clear all data with a single action

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
├── utils.dart               # Utility functions and helpers
├── API/                     # External API integrations (future)
├── Charts/                  # Chart and visualization components
├── Data/
│   ├── Expense_data.dart   # Business logic provider for expenses
│   └── hive_database.dart  # Local database operations
├── Design/                  # UI design systems and themes
├── Model/
│   └── Expense_item.dart   # Data model for expense items
└── Screens/
    ├── main.dart
    ├── tabs_manager.dart           # Navigation and authentication manager
    ├── Home_Screen.dart            # Main dashboard screen
    ├── Login_Page.dart             # Biometric authentication screen
    ├── Balance_Overview.dart       # Financial overview visualization
    ├── addTransactionPage.dart     # Add/edit transaction screen
    ├── Second_Screen.dart          # Secondary screen (details)
    └── Settings/
        └── Settings.dart           # App settings screen
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: ^3.9.2 or later
- Dart SDK: ^3.9.2 or later
- Android 6.0 or later (for Android deployment)
- iOS 11.0 or later (for iOS deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Siddiqui-Shahid/SpendingTracker.git
   cd spending_tracker
   ```

2. **Get Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   
   For Android:
   ```bash
   flutter build apk
   ```
   
   For iOS:
   ```bash
   flutter build ios
   ```

## 📖 Usage

### Adding a Transaction

1. Open the app and authenticate with biometrics (if enabled)
2. Tap the "+" button to add a new transaction
3. Enter transaction details:
   - **Name/Description**: What the transaction is for
   - **Amount**: Transaction amount
   - **Type**: Select between Income or Expense
   - **Date**: Select the transaction date
4. Tap "Add" to save

### Managing Transactions

- **View All**: Scroll through transaction history on the home screen
- **Edit Transaction**: Tap on a transaction and select edit
- **Delete Transaction**: Swipe or tap delete on a transaction
- **Filter**: View transactions by type (income/expense)

### Security Settings

1. Go to Settings screen
2. Toggle "Enable Fingerprint" to activate/deactivate biometric authentication
3. Set authentication options based on device capabilities
4. Maximum 3 authentication attempts before locking out

### Managing Your Data

- **View Balance**: Current balance displayed prominently on home screen
- **Export Data**: Export all transactions to a file from settings
- **Reset All**: Clear all data and start fresh (use with caution)

## 📚 Documentation

### Core Modules

#### `ExpenseData` (Data/Expense_data.dart)
**Provider class for state management using ChangeNotifier**

Key Methods:
- `getExpenseList()`: Returns list of all expenses
- `getBalance()`: Retrieves current account balance
- `setBalance(double)`: Updates account balance
- `addExpense(ExpenseItem)`: Adds new expense to list
- `updateExpense(int, ExpenseItem)`: Modifies existing expense
- `deleteExpense(int)`: Removes expense from list
- `eraseAndResetAll()`: Clears all data
- `getSavedSettings(int)`: Retrieves saved app settings

#### `ExpenseItem` (Model/Expense_item.dart)
**Data model representing a single transaction**

Properties:
- `name` (String): Transaction description
- `dateTime` (DateTime): Transaction timestamp
- `amount` (String): Transaction amount
- `type` (String): "income" or "expense"

#### `HiveDataBase` (Data/hive_database.dart)
**Local database operations using Hive**

Key Methods:
- `saveData(List)`: Persists expense list to database
- `readData()`: Retrieves all stored expenses
- `saveBalance(double)`: Saves account balance
- `readBalance()`: Retrieves current balance
- `getSettings()`: Gets app settings
- `getFingerprintEnabled()`: Checks biometric setting status
- `eraseAndReset()`: Clears database

#### `TabsManager` (Screens/tabs_manager.dart)
**Main navigation and authentication manager**

Features:
- Biometric authentication with retry mechanism (max 3 attempts)
- Tab-based navigation between screens
- Device capability checking
- Fallback authentication handling

Key Methods:
- `_checkFingerprint()`: Initiates biometric authentication
- `_navigateToPage()`: Handles tab navigation

#### `HomeScreen` (Screens/Home_Screen.dart)
**Main dashboard displaying balance and transactions**

Features:
- Real-time balance display
- Transaction history with categorization
- Quick access to add transactions
- Edit mode for bulk operations
- Transactions sorting and filtering

#### `AddTransactionPage` (Screens/addTransactionPage.dart)
**Screen for creating and editing transactions**

Features:
- Form validation
- Date/time picker
- Transaction type selection (income/expense)
- Edit existing transactions
- Animated transitions

#### `LoginScreen` (Screens/Login_Page.dart)
**Biometric authentication screen**

Features:
- Biometric prompt
- Fallback options
- Error handling
- Retry mechanism

#### `SettingsScreen` (Screens/Settings/Settings.dart)
**App configuration and management**

Features:
- Biometric authentication toggle
- Currency selection
- Data export
- App reset functionality
- Device information display

### Architecture

**State Management**: Provider pattern with ChangeNotifier
- Centralized state management using `ExpenseData` provider
- Real-time UI updates when data changes
- Efficient widget rebuilding

**Data Persistence**: Hive NoSQL database
- Fast local storage for transactions
- No internet required
- Secure data storage

**UI Framework**: Flutter with Material Design 3
- Responsive layouts
- Platform-specific widgets
- Smooth animations

**Authentication**: local_auth package
- Biometric authentication (fingerprint, face)
- Device-level security
- Fallback mechanisms

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `local_auth` | ^2.3.0 | Biometric authentication |
| `file_picker` | ^10.3.3 | File selection for data export |
| `permission_handler` | ^12.0.1 | Runtime permission management |
| `device_info_plus` | ^12.1.0 | Device information access |
| `provider` | - | State management |
| `hive_flutter` | - | Local database |

## 🛠️ Build & Deployment

### Android Build

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle (for Play Store)
flutter build appbundle --release
```

### iOS Build

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Platform-Specific Configuration

**Android** (`android/app/build.gradle.kts`):
- Minimum SDK: 21
- Target SDK: 34+
- Permissions configured in `AndroidManifest.xml`

**iOS** (`ios/Runner/Info.plist`):
- Biometric permissions configured
- File picker permissions configured

## 🔐 Security Considerations

1. **Biometric Authentication**: Uses device's secure biometric hardware
2. **Local Storage**: All data stored locally with device-level encryption
3. **Permission Handling**: Requests only necessary permissions at runtime
4. **Secure Settings**: Biometric settings encrypted in Hive database

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🐛 Troubleshooting

### Biometric Authentication Not Working
- Check if device has biometric hardware enrolled
- Enable fingerprint/face recognition in device settings
- Ensure app has biometric permissions
- Check `local_auth` compatibility with your device

### Data Not Persisting
- Verify Hive database initialization in `main.dart`
- Check device storage permissions
- Ensure database files aren't corrupted

### UI Issues
- Run `flutter clean` and `flutter pub get`
- Rebuild the app
- Check Flutter and Dart versions

## 📝 Code Style

- Follow Dart style guidelines
- Use descriptive variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source. See LICENSE file for details.

## 👤 Author

**Muhammed Shahid Siddiqui**
- GitHub: [@Siddiqui-Shahid](https://github.com/Siddiqui-Shahid)

## 📞 Support

For support, please open an issue on GitHub or contact the author.

---

**Last Updated**: October 2025
**App Version**: 1.0.0
