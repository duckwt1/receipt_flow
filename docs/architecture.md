# Architecture

ReceiptFlow follows a small MVVM and repository structure. Dependencies move from UI to domain interfaces and then into data implementations.

```text
View
  ↓
ViewModel
  ↓ (only when business logic has multiple steps or is reusable)
UseCase
  ↓
Repository interface
  ↓
Repository implementation
  ↓
Service
  ↓
SQLite / ML Kit / camera / file system
```

Expense CRUD goes directly from its ViewModel to `ExpenseRepository`; wrapping each CRUD call in a use case would add no useful rule. OCR parsing and report aggregation use cases because they transform data and are independently testable.

Domain `Expense` and `ParsedReceipt` are independent of SQLite rows and widgets. `ExpenseModel` is the data mapping boundary. Views render immutable state exposed by their feature ViewModels. Riverpod providers in `lib/app/providers/` compose services, repositories, use cases, and ViewModels.
