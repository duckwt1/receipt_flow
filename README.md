# ReceiptFlow

ReceiptFlow is a personal expense tracker foundation, planned around offline receipt OCR, editable expense capture, and local SQLite storage.

## Features

- Offline receipt text recognition with Google ML Kit and heuristic merchant, amount, and date extraction.
- Reviewable OCR results and manual expense entry, backed by local SQLite storage.
- Receipt images copied into app documents storage; SQLite stores only their file paths.
- Dashboard, searchable/category-filtered expense list, detail/edit/delete, and spending reports.
- Animated donut and weekly bar charts drawn with `CustomPainter`.
- Light and dark themes, with system/light/dark selection in Settings.

## Architecture

The app uses MVVM, repository interfaces, and data-layer service abstractions. CRUD screens call repositories through their ViewModels. Receipt OCR parsing and expense aggregation are domain use cases. Camera, OCR, SQLite, image picking, and file storage are isolated in data services. See the `docs/` directory for details.

## Development

Requires Flutter and Dart versions compatible with `pubspec.yaml`.

```sh
flutter pub get
flutter analyze
flutter test
flutter test integration_test
```

Camera and ML Kit require a physical Android or iOS device (or a configured emulator with camera support). Expense data and receipt files remain local to the app.
