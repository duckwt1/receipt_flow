# OCR pipeline

1. The scan ViewModel asks the camera service for a capture or the image picker service for a gallery image.
2. `ReceiptRepository` copies the source image into app documents storage and returns its path.
3. `MlkitOcrService` runs Google ML Kit Text Recognition on device and returns raw text.
4. `ParseReceiptUseCase` finds a likely merchant, a total candidate near total keywords, and a validated `DD/MM/YYYY`, `DD-MM-YYYY`, or `DD.MM.YYYY` date.
5. The review screen shows confidence for each extracted field. The user can edit every field and must explicitly save.
6. The expense repository stores the reviewed data and the image path in SQLite.

The amount parser handles dot and comma thousands separators and avoids interpreting three-digit groups as decimal fractions. Candidate ranking favors proximity to total labels over the largest number on the receipt. Heuristics remain uncertain across receipt layouts, so review is always part of the flow.
