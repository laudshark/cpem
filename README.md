# Contract Profit & Expense Manager

Contract Profit & Expense Manager (CPEM) is a cross-platform Flutter application for tracking contract expenses, monitoring profitability, and reviewing business financial performance from a single codebase.

## Current foundation

This repository currently includes:

- a Flutter app shell for Android, iOS, Windows, macOS, and Linux
- core domain models for contracts, expenses, and income
- an offline-first in-memory repository with demo data
- dashboard, contracts, ledger, and reports views
- profit, loss, margin, and category analytics calculations

## Why Flutter

Flutter is the most direct fit for the stated target platforms with one UI codebase and a clean path for offline storage and future sync.

## Project structure

```text
lib/
  app/
  core/
    models/
    repositories/
    state/
    theme/
    utils/
  features/
    contracts/
    dashboard/
    ledger/
    reports/
  shared/widgets/
docs/
test/
```

## Run locally

1. Install Flutter.
2. From this directory, generate platform folders if needed:

```bash
flutter create .
```

3. Start the app:

```bash
flutter run
```

For Chrome debug runs on this Windows setup, use the project starter wrapper:

```bash
flutter run -d chrome --frontend-server-starter-path tool/flutter_web_frontend_server_starter.dart
```

## Next engineering steps

1. Replace the in-memory repository with SQLite or Drift for offline persistence.
2. Add create/edit forms for contracts, expenses, and income records.
3. Add authentication and cloud sync for multi-device access.
4. Add PDF, CSV, and Excel export workflows.
5. Add automated tests for reports, summaries, and sync conflict handling.
