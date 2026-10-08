# Database and receipt files

`SqliteDatabaseService` creates `receipt_flow.db` at schema version 1. The `expenses` table stores merchant, amount, expense date, category enum name, optional receipt path and raw OCR text, and creation/update timestamps. Category and date indexes support filtering. Schema changes should increment `_databaseVersion` and add a forward-only `onUpgrade` migration.

SQLite operations are hidden behind `DatabaseService`; `ExpenseRepositoryImpl` maps rows to domain entities. Expense deletion removes the database row first and then attempts to remove its image. A failed file deletion leaves an orphaned image rather than a database row pointing at a missing expense.

Receipt images are copied into the app documents `receipts` directory under collision-resistant names. Image bytes are never written to SQLite.
