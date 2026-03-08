# CPEM Architecture

## Chosen approach

- UI framework: Flutter
- State management: `ChangeNotifier` for the initial foundation
- Data access: repository abstraction
- Initial storage: in-memory demo repository
- Planned offline storage: SQLite or Drift
- Planned sync: background job queue with conflict resolution based on timestamps and record versioning

## Bounded areas

### Contracts

Stores client, value, lifecycle dates, and status for each project or contract.

### Expenses

Stores operational and project-linked spending with category, vendor, date, and payment details.

### Income

Stores contract payments, advances, milestone payments, and other revenue streams.

### Reporting

Aggregates financial totals by contract, category, and time period.

## Offline-first path

1. Write records to the local database immediately.
2. Mark unsynced mutations in a local sync queue.
3. Push queued changes when connectivity is available.
4. Pull remote deltas and reconcile using version metadata.

## Core formulas

- Profit = Total Revenue - Total Expenses
- Profit Margin = (Profit / Revenue) * 100

## Immediate next layer

- `LocalFinanceRepository` using Drift
- form workflows for create and edit actions
- attachment storage for receipt images
- export services for PDF, CSV, and Excel
