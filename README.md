## TsekBook)

A Flutter-based **digital bookkeeping** app for small businesses. The app uses **double‑entry accounting** and a seeded **Chart of Accounts** to power:

- **Dashboard** (liquidity, performance snapshots)
- **Journal** (transaction history)
- **Ledger** (account balances by category)
- **Reports** (Income Statement, Balance Sheet, Cash Flow + PDF export)
- **Accounts** (Chart of Accounts management)
- **Quick Actions** (guided “quick entry” forms that post balanced Dr/Cr journal entries)

---

## Tech stack

- **Flutter** (Material 3)
- **Dart SDK**: see `pubspec.yaml` (`environment.sdk`)
- **Local DB**: [Drift](https://drift.simonbinder.eu/) (SQLite) via `drift` + `drift_flutter`
- **Persistence**: `shared_preferences` (onboarding + theme)
- **PDF export**: `pdf` + `printing`
- **UI utilities**: `intl`, `grouped_list`, `sticky_headers`, `tutorial_coach_mark`

---

## Project structure (high level)

### App entry + navigation

- **App entry**: `lib/main.dart`
  - Handles onboarding first-run flow (`SharedPreferences`)
  - Initializes `ThemeService`
  - Declares named routes (profile, settings, reports, user guide, about us)
- **Main tabs**: `lib/main_navigation.dart`
  - `IndexedStack` tabs:
    - Dashboard (`lib/features/dashboard/`)
    - Journal (`lib/features/journal/`)
    - Ledger (`lib/features/ledger/`)
    - Reports (`lib/features/reports/`)
    - Accounts (`lib/features/accounts/`)
- **App bar menu**: `lib/core/widgets/appbar.dart`
  - Profile, Settings, User Guide, About Us

### Features

Main feature folders live under `lib/features/` (examples):

- `dashboard/` – dashboard KPIs + quick action entry point
- `journal/` – journal list + creation
- `ledger/` – ledger balances and transactions
- `reports/` – income statement / balance sheet / cash flow
- `accounts/` – chart of accounts UI
- `quick_action/` – quick entry menu + view screens + accounting wiring
- `userguide/` – FAQs, article-style guide, About Us
- `settings/`, `profile/`, `onboarding/`, `splash_screen/`

---

## Database (Drift)

### Where it lives

- **Database definition**: `lib/core/database/app_database.dart`
- **Migration + seeding**: `lib/core/database/db_migration.dart`
- **Tables**: `lib/core/database/tables/`
  - `accounts_table.dart`
  - `account_categories_table.dart`
  - `journal_table.dart`
  - `transactions_table.dart`
  - `user_table.dart`
- **DAOs**: `lib/core/database/daos/`
  - `UsersDao`, `AccountsDao`, `LedgerDao`, `JournalEntryDao`, `ReportsDao`

### Schema version

- `AppDatabase.schemaVersion` is currently **7** in `lib/core/database/app_database.dart`.

### Seeding

`db_migration.dart` `onCreate`:
- creates all tables
- seeds Account Categories
- seeds the Chart of Accounts (with **account codes** + **normal balance**)
- seeds a default user profile

### Important caveat: upgrades

`db_migration.dart` currently has an **empty `onUpgrade`**. That means:
- if you change account codes / add accounts, **existing installed apps may not get them**
- posting by account code can fail if the code doesn’t exist in the local DB yet

The repo includes a reminder:

```text
lib/core/database/zzzNOTEzzz
If MODIFICATION on DATABASE FOLDER
- increase the schema version
- dart run build_runner build -d
- uninstall the app (via phone or emulator)
```

---

## Accounting model (double-entry)

All transactions are stored as:
- a **Journal** row (date, description, optional reference)
- multiple **Transaction** rows (each line has `debit` and `credit`)

### Quick Action posting service

Quick Actions post balanced entries via:
- `lib/features/quick_action/quick_action_journal_service.dart`

Key types:
- `TemplateLine(accountCode, isDebit, amount)` – lightweight Dr/Cr template
- `QuickActionAccounts` – **constants for account codes**

> Critical: `QuickActionAccounts` **must match** the codes seeded in `db_migration.dart`.

---

## Quick Actions (quick entry)

### Entry point

Dashboard → Quick Actions → `lib/features/quick_action/quick_actions_screen.dart`

### View screens

Quick action screens live in `lib/features/quick_action/views/`:

- Receive Money
  - `collect_money_view.dart`
  - `invest_to_business_view.dart`
  - `borrow_money_view.dart`
  - `sell_products_view.dart`
- Purchase
  - `record_purchase_view.dart` (Supplies/Equipment/Furniture/Land/Building/Vehicle)
- Banking
  - `banking_view.dart` (Deposit / Withdraw)
- Inventory & Production
  - `inventory_view.dart` (Acquire Raw Materials / Produce Finished Goods)
- Other Actions
  - `pay_your_debt_view.dart`
  - `disburse_funds_view.dart`
  - `lend_money_view.dart`
  - `settle_operations_view.dart`
  - `pay_workers_view.dart` (Pay Employees)
  - `consume_supplies_view.dart`
  - `fund_marketing_view.dart`
  - `refund_to_customers_view.dart`
  - `record_other_expense_view.dart` (Bank Fees / Tax / Interest / Miscellaneous)

Shared UI building blocks:
- `lib/features/quick_action/widgets/quick_action_shared_ui.dart`

Common UX patterns include:
- Amount card + validation
- Cash/Bank chips (+ optional balances)
- “Current / After” balance display for cash/bank where relevant
- Disable Save when insufficient balance for outflows

---

## Reports + PDF export

### Reports screens

- Income Statement: `lib/features/incomestatement/incomestatement_screen.dart`
- Balance Sheet: `lib/features/balancesheet/balance_sheet_screen.dart`
- Cash Flow: `lib/features/cashflow/cash_flow_screen.dart`

### PDF export

- `lib/core/utils/pdf_export_service.dart`
  - `exportIncomeStatement(...)`
  - `exportBalanceSheet(...)`
  - `exportCashFlowStatement(...)`

---

## Theming (Light/Dark/System)

- Themes: `lib/core/theme/app_theme.dart`
- Theme persistence: `lib/core/services/theme_service.dart`
  - stored under key `theme_mode` in `SharedPreferences`

---

## User Guide + About

- User Guide landing: `lib/features/userguide/user_guide_screen.dart`
  - FAQs: `lib/features/userguide/faq_screen.dart`
  - Article-style guide: `lib/features/userguide/article_user_guide_screen.dart`
- About Us: `lib/features/userguide/about_us_screen.dart`
- Both are accessible from the app bar menu (`CustomAppBar`)

---

## Assets

Declared in `pubspec.yaml`:
- `assets/images/logo.png`

Launcher icon config:
- `flutter_launcher_icons` in `pubspec.yaml`

---

## Getting started (dev)

### Prerequisites

- Flutter SDK installed
- Dart SDK matching `pubspec.yaml` constraints

### Install dependencies

```bash
flutter pub get
```

### Code generation (Drift)

Run when you change database tables/DAOs:

```bash
dart run build_runner build -d
```

### Run

```bash
flutter run
```

---

## Release notes (quick reference)

From `lib/core/database/zzzNOTEzzz`:

- Update Android label: `android/app/src/main/AndroidManifest.xml` (`android:label`)
- Generate launcher icons:

```bash
dart run flutter_launcher_icons
```

- Run release build:

```bash
flutter run --release
```

- APK output path:
  - `build/app/outputs/flutter-apk/`

---

## Troubleshooting

### “Failed to transact” / “Failed to save entry” in Quick Actions

Most common cause: **account code mismatch** between:
- `QuickActionAccounts` (`quick_action_journal_service.dart`)
- the seeded chart of accounts (`db_migration.dart`)
- and the local installed app DB (especially when `onUpgrade` is empty)

Fix for development:
- bump `schemaVersion`
- run `build_runner`
- uninstall / clear app data so `onCreate` seeds the updated accounts

### Walkthroughs reappearing

Walkthrough persistence helpers exist in `lib/core/services/walkthrough_service.dart`, but completion tracking may be disabled/commented.

---

## License

This project is licensed under the [Apache-2.0 License](https://github.com/NaldCapuno/bookify/blob/main/LICENSE)
