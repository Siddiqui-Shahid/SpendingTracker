# Spending Tracker - Complete Documentation

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Modules](#core-modules)
4. [Features Documentation](#features-documentation)
5. [State Management](#state-management)
6. [Database Layer](#database-layer)
7. [Authentication System](#authentication-system)
8. [UI/UX Architecture](#uiux-architecture)
9. [Data Flow](#data-flow)
10. [API Reference](#api-reference)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                   User Interface                    │
│  (Flutter Widgets - Material Design)                │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│             State Management Layer                  │
│  (Provider Pattern - ChangeNotifier)               │
│  ↓                                                  │
│  ExpenseData (Central State Manager)                │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│             Business Logic Layer                    │
│  - Expense calculations                             │
│  - Balance management                               │
│  - Settings handling                                │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│             Data Persistence Layer                  │
│  (Hive - NoSQL Local Database)                      │
│  - expense_database Box                             │
│  - Balance storage                                  │
│  - Settings persistence                             │
└─────────────────────────────────────────────────────┘
```

### Design Patterns Used

1. **Provider Pattern**: State management with ChangeNotifier
2. **Repository Pattern**: HiveDataBase abstraction
3. **Model-View-Controller**: Clear separation of concerns
4. **Singleton Pattern**: Single instance of ExpenseData provider

---

## Project Structure

### Directory Organization

```
lib/
├── main.dart                           # App entry point
├── utils.dart                          # Global utility functions
│
├── API/                                # External API integrations
│   └── [Future API endpoints]
│
├── Charts/                             # Data visualization components
│   └── [Chart widgets and utilities]
│
├── Data/                               # Data layer
│   ├── Expense_data.dart              # State management provider ⭐
│   └── hive_database.dart             # Database abstraction layer
│
├── Design/                             # Design system
│   ├── [Theme configurations]
│   ├── [Color palettes]
│   └── [Widget styles]
│
├── Model/                              # Data models
│   └── Expense_item.dart              # Expense/Income data model ⭐
│
└── Screens/                            # UI Screens
    ├── tabs_manager.dart              # Navigation & Auth manager ⭐
    ├── Home_Screen.dart               # Dashboard
    ├── Login_Page.dart                # Biometric auth
    ├── Balance_Overview.dart          # Financial overview
    ├── addTransactionPage.dart        # Add/Edit transaction
    ├── Second_Screen.dart             # Additional screen
    └── Settings/
        └── Settings.dart              # App settings
```

**⭐ = Core files with comprehensive documentation**

---

## Core Modules

### 1. ExpenseData (Data/Expense_data.dart)

**Purpose**: Central state manager using Provider pattern with ChangeNotifier

**Key Responsibilities**:
- Manages expense and income transactions
- Maintains account balance
- Handles app settings
- Coordinates database operations
- Notifies UI of state changes

**Architecture Pattern**: Provider + ChangeNotifier

**Key Properties**:
```dart
final db = HiveDataBase();                    // Database instance
List<ExpenseItem> overallExpenseList = [];    // All transactions
List<int> savedSettings = [0, 0, 0, 0];      // Settings array
```

**Settings Array Structure**:
- Index 0: Currency selection
- Index 1: Reserved for future use
- Index 2: Fingerprint auth enabled (1/0)
- Index 3: Reserved for future use

**Usage Example**:
```dart
// Listen to changes
final expenseData = Provider.of<ExpenseData>(context);

// Add expense
expenseData.addExpense(expenseItem);

// Get balance
double balance = expenseData.getBalance();

// Check biometric
if (expenseData.getFingerprintEnabled()) {
  // Authenticate
}
```

### 2. ExpenseItem (Model/Expense_item.dart)

**Purpose**: Data model representing a single transaction

**Properties**:
```dart
class ExpenseItem {
  final String name;           // Transaction description
  final DateTime dateTime;     // Transaction timestamp
  final String amount;         // Amount (stored as string)
  final String type;           // "income" or "expense"
}
```

**Validation Rules**:
- `name`: Non-empty string
- `amount`: Numeric string (e.g., "50.00")
- `type`: Must be "income" or "expense"
- `dateTime`: Valid DateTime object

**Helper Methods**:
```dart
String getTypeDisplay()              // Returns formatted type
String getFormattedAmount(currency)  // Returns currency formatted amount
Map<String, dynamic> toMap()         // Serialize for database
factory ExpenseItem.fromMap()        // Deserialize from database
```

### 3. HiveDataBase (Data/hive_database.dart)

**Purpose**: Abstract database operations using Hive NoSQL

**Hive Box Structure**:
- Box name: `"expense_database"`
- Stores transactions as serialized objects
- Persistent storage on device

**Key Operations**:
```dart
// Save/Read transactions
List<ExpenseItem> readData()
void saveData(List<ExpenseItem> expenses)

// Balance management
double readBalance()
void saveBalance(double balance)

// Settings
int getSettings()
void saveSettings(List<int> settings)

// Biometric
int getFingerprintEnabled()
void saveFingerprintEnabled(int value)

// Cleanup
Future<void> eraseAndReset()
```

**Database Initialization** (in main.dart):
```dart
await Hive.initFlutter();
await Hive.openBox("expense_database");
```

### 4. TabsManager (Screens/tabs_manager.dart)

**Purpose**: Main navigation screen and authentication orchestrator

**Key Features**:
- Tab-based navigation
- Biometric authentication with retry logic
- App lock mechanism
- Device capability checking

**Authentication Flow**:
1. Check if fingerprint is enabled
2. Verify device biometric capability
3. Attempt authentication (max 3 attempts)
4. Lock app after failed attempts
5. Show fallback dialog if biometric unavailable

**State Variables**:
```dart
bool _locked = false;              // App lock status
int _attempts = 0;                 // Current attempt count
final int _maxAttempts = 3;        // Maximum attempts
int currentPageIndex = 0;          // Current tab
```

**Navigation Structure**:
- Tab 0: HomeScreen (Main dashboard)
- Tab 1: LoginScreen (Secondary screen)

### 5. HomeScreen (Screens/Home_Screen.dart)

**Purpose**: Main dashboard displaying balance and transactions

**Display Elements**:
- Current account balance (prominent)
- Transaction history (scrollable list)
- Quick-add transaction button
- Edit mode toggle
- Transaction filtering options

**Interaction Features**:
- Add new transaction (animated slide transition)
- Edit existing transaction
- Delete transaction
- View transaction details
- Refresh data

**Data Binding**:
- Real-time balance updates
- Transaction list changes
- Settings updates

### 6. AddTransactionPage (Screens/addTransactionPage.dart)

**Purpose**: Screen for creating and editing transactions

**Form Fields**:
- Transaction name/description
- Amount (numeric input)
- Transaction type (dropdown: Income/Expense)
- Date and time picker

**Validation**:
- Name: Non-empty
- Amount: Valid number
- Type: Selected
- Date: Valid and not future-dated

**Operations**:
- Add new transaction
- Edit existing transaction
- Cancel and return

**UI Animation**:
- Slide transition from bottom
- Smooth field interactions

### 7. LoginScreen (Screens/Login_Page.dart)

**Purpose**: Biometric authentication interface

**Authentication Methods**:
- Fingerprint (primary)
- Face recognition (if supported)
- System fallback

**Error Handling**:
- Biometric not enrolled
- Device not supported
- Authentication failure
- Retry mechanism

### 8. SettingsScreen (Screens/Settings/Settings.dart)

**Purpose**: App configuration and management

**Settings Options**:
- Biometric authentication toggle
- Currency selection
- Device information display
- Data export functionality
- Factory reset option

---

## Features Documentation

### Feature 1: Expense Tracking

**Description**: Add, view, and manage financial transactions

**Implementation Details**:
- Transactions stored in memory list and database
- Real-time balance calculation
- Income adds to balance, expense subtracts
- Each transaction has timestamp for sorting

**User Workflow**:
1. Tap "Add" button
2. Enter transaction details
3. Select type (income/expense)
4. Choose date
5. Save transaction

**Data Flow**:
```
User Input → AddTransactionPage → ExpenseData.addExpense() 
→ Update memory list → Notify listeners → HomeScreen updated
→ HiveDataBase.saveData() → Persisted to device
```

### Feature 2: Balance Management

**Description**: Track current account balance in real-time

**Calculation Logic**:
```
Balance = Sum of all income - Sum of all expenses

For each transaction:
  if type == "income":
    balance += amount
  else:
    balance -= amount
```

**Update Triggers**:
- Add transaction
- Edit transaction (amount change)
- Delete transaction
- App startup (load from database)

**Persistence**:
- Stored in Hive database
- Loaded on app start
- Synced after each transaction

### Feature 3: Biometric Authentication

**Description**: Secure app access with fingerprint/face recognition

**Flow**:
1. App startup → Check if biometric enabled
2. Verify device has biometric hardware
3. Request authentication
4. User authenticates
5. Access granted → Show dashboard
6. Access denied → Retry (max 3 attempts)
7. Failed attempts → Lock app

**Error Scenarios**:
- No biometric enrolled → Show dialog
- Device not supported → Show dialog
- Authentication canceled → Retry
- Max attempts exceeded → Lock app

**Code Reference**:
```dart
LocalAuthentication auth = LocalAuthentication();
final authenticated = await auth.authenticate(
  localizedReason: 'Authenticate to access the app',
  options: const AuthenticationOptions(
    biometricOnly: true,
    stickyAuth: true,
  ),
);
```

### Feature 4: Transaction History

**Description**: View all past transactions with details

**Display Information**:
- Transaction name
- Date and time
- Amount
- Type (income/expense)
- Running balance (optional)

**Sorting**:
- Default: Most recent first
- By date: Chronological
- By type: Income/Expense grouped

**Actions**:
- View details
- Edit transaction
- Delete transaction

### Feature 5: Data Persistence

**Description**: Save all data locally without cloud

**Storage Method**: Hive NoSQL Database
- Local file-based storage
- Fast access
- No internet required
- Automatic serialization

**Stored Data**:
- All transactions
- Current balance
- App settings
- Biometric status

**Backup Strategy**:
- Data export to file
- Manual backup capability
- Factory reset option

### Feature 6: Settings Management

**Description**: Customize app behavior and preferences

**Available Settings**:
- Biometric authentication (enable/disable)
- Currency selection
- Data export
- App reset
- Device information

**Settings Persistence**:
- Stored as array: [currency, reserved, fingerprint, reserved]
- Loaded on app start
- Updated in real-time

---

## State Management

### Provider Pattern Implementation

**Architecture**:
```
ChangeNotifierProvider
    ↓
ExpenseData (ChangeNotifier)
    ↓
Automatic UI Rebuild
```

**State Update Flow**:
```
1. User Action (e.g., add expense)
    ↓
2. Call Provider method (expenseData.addExpense())
    ↓
3. Update internal state
    ↓
4. Persist to database
    ↓
5. Call notifyListeners()
    ↓
6. All listening widgets rebuild automatically
```

**Usage Patterns**:

**Pattern 1: Listen to all changes**
```dart
final expenseData = Provider.of<ExpenseData>(context);
// Rebuilds whenever ExpenseData notifies
```

**Pattern 2: Select specific value**
```dart
final balance = Provider.of<ExpenseData>(context)
  .select((data) => data.getBalance());
```

**Pattern 3: No rebuild (one-time access)**
```dart
final expenseData = Provider.of<ExpenseData>(context, listen: false);
// Use for buttons, single operations
```

**Listener Widget** (Advanced):
```dart
Selector<ExpenseData, double>(
  selector: (_, data) => data.getBalance(),
  builder: (context, balance, child) {
    return Text('Balance: $balance');
  },
);
```

### Performance Considerations

1. **Selective Listening**: Use `select()` to listen only to changed values
2. **Listen: false**: Use for one-time operations
3. **Widget Hierarchy**: Place providers high in widget tree
4. **Immutability**: Each state change returns new object

---

## Database Layer

### Hive Setup and Initialization

**Initialization** (main.dart):
```dart
void main() async {
  await Hive.initFlutter();
  await Hive.openBox("expense_database");
  runApp(const MyApp());
}
```

### Data Storage Structure

**Box: "expense_database"**

Stores:
1. **Transactions List** (Key: "expenses")
   - List<ExpenseItem> serialized objects

2. **Balance** (Key: "balance")
   - Double value

3. **Settings** (Key: "settings")
   - List<int> array

4. **Biometric Status** (Key: "fingerprint")
   - Integer (1 = enabled, 0 = disabled)

### Serialization

**ExpenseItem Serialization**:
```dart
// To Database (toMap)
Map<String, dynamic> toMap() {
  return {
    'name': name,
    'dateTime': dateTime,
    'amount': amount,
    'type': type,
  };
}

// From Database (fromMap)
factory ExpenseItem.fromMap(Map<String, dynamic> map) {
  return ExpenseItem(
    name: map['name'] ?? '',
    dateTime: map['dateTime'] ?? DateTime.now(),
    amount: map['amount'] ?? '0',
    type: map['type'] ?? 'expense',
  );
}
```

### Database Operations

**Save Data**:
```dart
Future<void> saveData(List<ExpenseItem> expenses) async {
  final box = Hive.box("expense_database");
  await box.put("expenses", expenses);
}
```

**Read Data**:
```dart
List<ExpenseItem> readData() {
  final box = Hive.box("expense_database");
  final expenses = box.get("expenses") ?? [];
  return List<ExpenseItem>.from(expenses);
}
```

**Clear Data**:
```dart
Future<void> eraseAndReset() async {
  final box = Hive.box("expense_database");
  await box.clear();
}
```

### Performance Tips

1. **Batch Operations**: Save multiple items together
2. **Lazy Loading**: Load data only when needed
3. **Caching**: Keep frequently accessed data in memory
4. **Async Operations**: Use async/await for long operations

---

## Authentication System

### Biometric Authentication Architecture

```
┌──────────────────────────────────────────┐
│         App Startup (TabsManager)        │
└──────────────┬───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│  Check Biometric Enabled (getFingerprintEnabled)
└──────────────┬───────────────────────────┘
               │
        ┌──────▼──────┐
        │             │
    Enabled       Not Enabled
        │             │
        ▼             ▼
   Authenticate   Show Home
   LocalAuth       Screen
        │
┌───────▼─────────────────────┐
│ Verify Device Capability    │
│ - canCheckBiometrics        │
│ - isDeviceSupported         │
└───────┬─────────────────────┘
        │
   ┌────▼────┐
   │          │
Capable   Not Capable
   │          │
   ▼          ▼
Authenticate Show Dialog
          │
   ┌──────▼────────┐
   │               │
Success       Failure
   │               │
   ▼               ▼
Show Home     Retry/Lock
Screen      (max 3 attempts)
```

### Authentication Methods

**1. Fingerprint (Primary)**
- Fast and secure
- User-friendly
- Requires enrolled fingerprint

**2. Face Recognition (Device-dependent)**
- Modern devices support
- Similar to fingerprint
- System-level security

**3. Fallback (System Default)**
- Used if biometric fails
- Device PIN/Password
- Handled by OS

### Retry Mechanism

```dart
int _maxAttempts = 3;
int _attempts = 0;

while (_attempts < _maxAttempts && !authenticated) {
  try {
    authenticated = await auth.authenticate(...);
  } catch (e) {
    debugPrint('Biometric error: $e');
  }
  
  if (!authenticated) {
    _attempts++;
  }
}

if (!authenticated) {
  _locked = true;  // Lock the app
}
```

### Permissions Required

**Android** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

**iOS** (Info.plist):
```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to secure your financial data</string>
<key>NSBiometricsUsageDescription</key>
<string>We use biometrics to protect your account</string>
```

---

## UI/UX Architecture

### Screen Structure

#### HomeScreen
```
┌─────────────────────────────┐
│  Header (Balance Display)   │
├─────────────────────────────┤
│  Current Balance: $1,250.00 │
└─────────────────────────────┘
        ↓
┌─────────────────────────────┐
│  Transaction History        │
│  - Recent transactions      │
│  - Scrollable list          │
│  - Edit/Delete options      │
├─────────────────────────────┤
│ [Transaction Item 1]        │
│ [Transaction Item 2]        │
│ [Transaction Item 3]        │
└─────────────────────────────┘
        ↓
┌─────────────────────────────┐
│  FAB (Add Button)           │
│  Press to add transaction   │
└─────────────────────────────┘
```

#### AddTransactionPage
```
┌─────────────────────────────┐
│  Title: Add Transaction     │
├─────────────────────────────┤
│  [Name Text Field]          │
│  [Amount Input]             │
│  [Type Dropdown]            │
│  [Date Picker]              │
│  [Time Picker]              │
├─────────────────────────────┤
│  [Cancel] [Add/Update]      │
└─────────────────────────────┘
```

#### SettingsScreen
```
┌─────────────────────────────┐
│  Settings                   │
├─────────────────────────────┤
│  ☑ Enable Fingerprint      │
│  Currency: USD              │
│  Device Info                │
│  Export Data                │
│  [Factory Reset]            │
└─────────────────────────────┘
```

### Navigation Flow

```
Splash/Auth
    ↓
TabsManager (Main Navigation)
    ├─ Tab 0: HomeScreen
    │   ├─ Add Transaction → AddTransactionPage
    │   ├─ Edit Transaction → AddTransactionPage
    │   └─ View Details → SecondScreen
    │
    └─ Tab 1: LoginScreen
        └─ Settings button → SettingsScreen
```

### Material Design Implementation

- **Primary Color**: Blue/Dark Blue
- **Accent Color**: Teal/Green
- **Typography**: Roboto (system default)
- **Spacing**: 16px baseline grid
- **Elevation**: Subtle shadows for hierarchy

### Responsive Design

- **Portrait Mode**: Primary layout
- **Landscape Mode**: Adjusted list width
- **Small Screens**: Simplified navigation
- **Large Screens**: Multi-column layout (future)

---

## Data Flow

### User Adds Expense

```
1. User Interaction
   └─ Tap "+" button on HomeScreen

2. UI Transition
   └─ Navigate to AddTransactionPage
   └─ Show transaction form

3. User Input
   └─ Enter: name, amount, type, date
   └─ Tap "Add"

4. Validation
   └─ Check all fields filled
   └─ Validate amount is numeric
   └─ Validate type is selected

5. Create Object
   └─ ExpenseItem(
        name: input,
        amount: input,
        type: input,
        dateTime: selected
      )

6. State Update
   └─ expenseData.addExpense(item)
   └─ Add to overallExpenseList
   └─ Call notifyListeners()

7. Database Persist
   └─ hiveDatabase.saveData(list)
   └─ Write to Hive box

8. UI Rebuild
   └─ HomeScreen receives notification
   └─ Transaction list refreshed
   └─ Balance recalculated
   └─ Navigate back to HomeScreen

9. Visual Feedback
   └─ New transaction appears in list
   └─ Balance updates
   └─ Smooth animation
```

### User Edits Transaction

```
1. User selects transaction
   └─ Long press on transaction item

2. Edit dialog shown
   └─ Can modify: name, amount, type, date

3. Update object
   └─ Create updated ExpenseItem

4. State Update
   └─ expenseData.updateExpense(index, updated)
   └─ Replace in list
   └─ Call notifyListeners()

5. Database Persist
   └─ hiveDatabase.saveData(list)

6. UI Rebuild
   └─ Transaction list refreshed
   └─ Balance recalculated if amount changed

7. Navigation
   └─ Return to HomeScreen
```

### User Deletes Transaction

```
1. User selects delete
   └─ Swipe right or tap delete button

2. Confirmation dialog
   └─ "Are you sure?"

3. Delete Operation
   └─ expenseData.deleteExpense(item)
   └─ Remove from overallExpenseList
   └─ Recalculate balance
   └─ Call notifyListeners()

4. Database Persist
   └─ hiveDatabase.saveData(list)
   └─ hiveDatabase.saveBalance(newBalance)

5. UI Rebuild
   └─ Transaction removed from list
   └─ Balance updated
   └─ Animation feedback
```

### App Startup with Authentication

```
1. App Launch
   └─ main.dart executed
   └─ Hive initialized
   └─ Database opened

2. Provider Setup
   └─ ExpenseData created
   └─ ChangeNotifierProvider initialized

3. TabsManager Mounted
   └─ didChangeDependencies called
   └─ _checkFingerprint triggered

4. Biometric Check
   └─ getFingerprintEnabled() check
   └─ If not enabled: Show HomeScreen
   └─ If enabled: Proceed to auth

5. Device Capability Check
   └─ canCheckBiometrics?
   └─ isDeviceSupported?
   └─ If not: Show dialog, skip auth

6. Authenticate
   └─ Show biometric prompt
   └─ User authenticates
   └─ Success: Show HomeScreen
   └─ Failure: Retry (max 3 times)
   └─ Locked: Lock app

7. Load Data
   └─ prepareData() called
   └─ Load transactions from database
   └─ Load balance
   └─ Load settings
   └─ Notify listeners

8. Display
   └─ HomeScreen rendered
   └─ Transactions displayed
   └─ Balance shown
   └─ Ready for user interaction
```

---

## API Reference

### ExpenseData Class

#### Public Methods

```dart
/// Expense Management
void addExpense(ExpenseItem newExpense)
void addIncome(ExpenseItem newIncome)
void deleteExpense(ExpenseItem expense)
void updateExpense(int index, ExpenseItem updatedExpense)
void clearAllExpenses()

/// Balance Management
double getBalance()
void setBalance(double balance)

/// Data Retrieval
List<ExpenseItem> getExpenseList()

/// Settings Management
int getSavedSettings(int settingNum)
void addSettings(int settingNum, int newSetting)
bool getFingerprintEnabled()
void setFingerprintEnabled(bool enabled)

/// Data Loading
void prepareData()

/// Data Clearing
Future<void> eraseAndResetAll()
```

### HiveDataBase Class

```dart
/// Transaction Operations
List<ExpenseItem> readData()
void saveData(List<ExpenseItem> expenses)

/// Balance Operations
double readBalance()
void saveBalance(double balance)

/// Settings Operations
int getSettings()
void saveSettings(List<int> settings)

/// Biometric Operations
int getFingerprintEnabled()
void saveFingerprintEnabled(int value)

/// Database Cleanup
Future<void> eraseAndReset()
```

### ExpenseItem Class

```dart
/// Constructor
ExpenseItem({
  required String name,
  required DateTime dateTime,
  required String amount,
  required String type,
})

/// Getters
String get name
DateTime get dateTime
String get amount
String get type

/// Helpers
String getTypeDisplay()
String getFormattedAmount(String currency)

/// Serialization
Map<String, dynamic> toMap()
factory ExpenseItem.fromMap(Map<String, dynamic> map)
```

---

## Best Practices

### 1. State Management

**✅ DO**:
- Use `Provider.of<ExpenseData>(context)` for listening
- Call `notifyListeners()` after state changes
- Use `listen: false` for one-time operations
- Leverage `select()` for specific values

**❌ DON'T**:
- Create multiple ExpenseData instances
- Bypass the provider for database operations
- Call `notifyListeners()` in loops
- Store ExpenseData in local variables

### 2. Database Operations

**✅ DO**:
- Always persist after state changes
- Use async/await for database operations
- Handle errors with try-catch
- Validate data before saving

**❌ DON'T**:
- Save to database without state change
- Use blocking operations on UI thread
- Ignore serialization errors
- Store sensitive data unencrypted

### 3. UI Development

**✅ DO**:
- Use Builder widgets for local state
- Leverage ListView for scrolling lists
- Use Padding/Margin consistently
- Implement proper error states

**❌ DON'T**:
- Use large single widgets
- Ignore state rebuilds
- Hardcode sizes and colors
- Skip loading states

### 4. Authentication

**✅ DO**:
- Check device capability before auth
- Implement retry logic
- Handle auth cancellation
- Provide fallback options

**❌ DON'T**:
- Assume biometric availability
- Ignore auth errors
- Store auth tokens insecurely
- Hardcode authentication logic

### 5. Error Handling

**✅ DO**:
- Wrap async operations in try-catch
- Show user-friendly error messages
- Log errors for debugging
- Recover gracefully from failures

**❌ DON'T**:
- Ignore exceptions silently
- Show technical error messages
- Crash on data parsing errors
- Leave UI in invalid state

### 6. Performance

**✅ DO**:
- Lazy-load data when possible
- Use const constructors
- Minimize widget rebuilds
- Cache expensive computations

**❌ DON'T**:
- Load all data at startup
- Rebuild entire screen on small changes
- Perform heavy operations on UI thread
- Create unnecessary objects

### 7. Code Organization

**✅ DO**:
- Separate concerns into different files
- Use meaningful variable names
- Add documentation comments
- Follow Dart style guide

**❌ DON'T**:
- Mix business logic with UI
- Use unclear abbreviations
- Leave code without comments
- Ignore code formatting

---

## Troubleshooting

### Issue: Biometric Authentication Not Working

**Symptoms**: App doesn't show biometric prompt

**Solutions**:
1. Check if device has biometric hardware
2. Verify biometric is enrolled in device settings
3. Ensure app has biometric permissions
4. Check `local_auth` package version compatibility
5. Restart device

**Debug Steps**:
```dart
final auth = LocalAuthentication();
print(await auth.canCheckBiometrics);
print(await auth.isDeviceSupported());
print(await auth.getAvailableBiometrics());
```

### Issue: Data Not Persisting

**Symptoms**: Transactions disappear after app restart

**Solutions**:
1. Verify Hive initialization in `main()`:
   ```dart
   await Hive.initFlutter();
   await Hive.openBox("expense_database");
   ```

2. Check `saveData()` is called after changes
3. Verify database file permissions
4. Check device storage space

**Debug Steps**:
```dart
final box = Hive.box("expense_database");
print(box.length);  // Should be > 0
print(await box.get("expenses"));
```

### Issue: UI Not Updating

**Symptoms**: Changes made but UI doesn't refresh

**Solutions**:
1. Verify `notifyListeners()` is called
2. Check `listen: true` in Provider.of()
3. Ensure Provider wraps the widget
4. Verify state actually changed

**Debug Steps**:
```dart
debugPrint('Before: $value');
expenseData.updateExpense(0, newItem);
debugPrint('After: ${expenseData.getExpenseList()}');
```

### Issue: High Memory Usage

**Symptoms**: App slow or crashes with large datasets

**Solutions**:
1. Implement pagination for transaction list
2. Use StreamBuilder instead of Future
3. Clear unnecessary cached data
4. Profile with Dart DevTools

**Optimization**:
```dart
// Don't load all data at once
// Load in chunks as user scrolls
final PagedList = [...transactions].skip(pageNumber * pageSize).take(pageSize).toList();
```

### Issue: Database Locked

**Symptoms**: "Database is locked" error

**Solutions**:
1. Ensure only one database instance
2. Use proper async/await patterns
3. Close database gracefully on exit
4. Restart app

### Issue: Transaction Amount Precision

**Symptoms**: Amount displays incorrectly (e.g., 10.20 shows as 10.2)

**Solutions**:
1. Use proper string formatting
2. Format amount when displaying:
   ```dart
   final formatted = double.parse(amount).toStringAsFixed(2);
   ```

### Issue: Performance Slow During Large Data Operations

**Symptoms**: App freezes when adding/deleting many transactions

**Solutions**:
1. Batch database operations
2. Use async operations:
   ```dart
   await Future.microtask(() => expenseData.addExpense(item));
   ```

3. Implement pagination
4. Use Isolate for heavy computation

---

## Advanced Topics

### Custom Serialization

For complex data types beyond ExpenseItem:

```dart
class Transaction {
  final String id;
  final ExpenseItem item;
  final String category;
  
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      item: ExpenseItem.fromMap(map['item'] as Map),
      category: map['category'] as String,
    );
  }
}
```

### Implementing Backup

```dart
Future<void> exportToFile() async {
  final expenses = expenseData.getExpenseList();
  final json = jsonEncode(expenses.map((e) => e.toMap()).toList());
  // Save to file using file_picker
}

Future<void> importFromFile() async {
  // Load from file
  final json = jsonDecode(fileContent);
  // Import to database
}
```

### Advanced Filtering

```dart
// Filter by date range
List<ExpenseItem> getExpensesByDateRange(DateTime start, DateTime end) {
  return expenseData.getExpenseList().where((item) {
    return item.dateTime.isAfter(start) && item.dateTime.isBefore(end);
  }).toList();
}

// Filter by amount range
List<ExpenseItem> getExpensesByAmountRange(double min, double max) {
  return expenseData.getExpenseList().where((item) {
    final amount = double.parse(item.amount);
    return amount >= min && amount <= max;
  }).toList();
}
```

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Compatibility**: Flutter ^3.9.2, Dart ^3.9.2
