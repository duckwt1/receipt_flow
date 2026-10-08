# 🧾 ReceiptFlow – Quản Lý Quỹ Sinh Viên & CLB Thông Minh

> **Ứng dụng di động quản lý chi tiêu và tự động bóc tách hóa đơn ngoại tuyến (On-Device OCR) phong cách FinTech / Ngân hàng số hiện đại.**  
> *Đồ án Mini-Project 3 — Học phần Phát triển Ứng dụng Di động Đa nền tảng (Cross-Platform Mobile App Development) — Trường Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU).*

[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-16%2F16%20Passed-10B981?logo=checkmarx&logoColor=white)](#kiểm-thử-tự-động-test-suite)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-6366F1)](docs/architecture.md)
[![Database](https://img.shields.io/badge/Database-Local%20SQLite-003B57?logo=sqlite&logoColor=white)](docs/database.md)
[![ML Kit](https://img.shields.io/badge/OCR-Google%20ML%20Kit%20On--Device-4285F4?logo=google&logoColor=white)](docs/ocr-pipeline.md)

---

## 📌 Mục Lục
1. [Giới thiệu tổng quan](#1-giới-thiệu-tổng-quan)
2. [Các tính năng nổi bật](#2-các-tính-năng-nổi-bật)
3. [Công nghệ sử dụng](#3-công-nghệ-sử-dụng)
4. [Kiến trúc ứng dụng](#4-kiến-trúc-ứng-dụng)
5. [Cấu trúc thư mục](#5-cấu-trúc-thư-mục)
6. [Hướng dẫn cài đặt & Khởi chạy](#6-hướng-dẫn-cài-đặt--khởi-chạy)
7. [Hướng dẫn sử dụng chi tiết](#7-hướng-dẫn-sử-dụng-chi-tiết)
8. [Kiểm thử tự động (Test Suite)](#8-kiểm-thử-tự-động-test-suite)
9. [Thông tin tác giả](#9-thông-tin-tác-giả)

---

## 1. Giới thiệu tổng quan

Trong đời sống sinh viên và hoạt động câu lạc bộ, thủ quỹ thường xuyên phải thu thập các hóa đơn bán lẻ giấy (siêu thị, văn phòng phẩm, ăn uống, trang thiết bị sự kiện). Việc nhập thủ công từng con số vào bảng tính Excel/Google Sheets rất tốn thời gian, dễ nhầm lẫn và khó theo dõi hạn mức ngân sách còn lại.

**ReceiptFlow** giải quyết triệt để bài toán trên:
* 📷 **Tự động quét và nhận diện hóa đơn trong tích tắc** bằng Google ML Kit chạy trực tiếp trên thiết bị (sub-100ms, không cần kết nối mạng, chi phí $0).
* 🧠 **Bộ giải tích Regex Heuristics thông minh** trích xuất chính xác số tiền tổng, ngày mua hàng và tên đơn vị bán lẻ theo thói quen định dạng hóa đơn tại Việt Nam.
* 💳 **Trải nghiệm giao diện Ngân hàng số (Banking UI/UX)**: Quản lý ngân sách thời gian thực với thẻ Hero sang trọng, theo dõi số dư còn lại và phân tích chi tiêu bằng biểu đồ Canvas độc quyền.

---

## 2. Các tính năng nổi bật

### 📷 2.1 Quét hóa đơn trực tiếp (Camera Viewfinder & OCR)
* Kính ngắm camera thời gian thực với 4 góc HUD màu xanh ngọc vẽ bằng Canvas.
* Hỗ trợ bật/tắt đèn flash trợ sáng ban đêm và chạm lấy nét đa điểm (Tap-to-Focus).
* Hỗ trợ chọn ảnh hóa đơn có sẵn từ thư viện ảnh thiết bị (`image_picker`).
* Tích hợp `google_mlkit_text_recognition` chạy On-Device: Bảo mật 100%, ngoại tuyến hoàn toàn, không gửi ảnh lên máy chủ đám mây.

### 🧠 2.2 Động cơ bóc tách Regex Heuristics & Thẩm định tương tác
* **Bóc tách số tiền thông minh (`MoneyParser`)**: Nhận diện chuẩn xác định dạng tiền tệ Việt Nam (`150.000 đ`, `150,000 VND`), thuật toán ưu tiên số nằm gần từ khóa tổng (`TOTAL`, `TỔNG CỘNG`, `THANH TOÁN`), tránh nhầm lẫn với số điện thoại hoặc mã số thuế.
* **Bóc tách ngày tháng**: Hỗ trợ các định dạng `DD/MM/YYYY`, `DD-MM-YYYY`, `DD.MM.YYYY`.
* **Trích xuất đơn vị bán**: Thuật toán heuristics phát hiện dòng tiêu đề in hoa ở phần đầu hóa đơn.
* **Màn hình kiểm tra tương tác (`ReceiptReviewView`)**: Hiển thị ảnh chụp đính kèm cùng huy hiệu điểm tin cậy (`Độ tin cậy cao`, `Độ tin cậy trung bình`, `Độ tin cậy thấp — vui lòng kiểm tra lại`), cho phép người dùng kiểm tra và chỉnh sửa trước khi lưu.

### 💳 2.3 Thẻ Quỹ Ngân sách & Số dư thời gian thực (`BankHeroCard`)
* Thẻ Hero phong cách ngân hàng số sang trọng với hiệu ứng ánh sáng gradient đa chiều.
* Hiển thị trực quan: **Số dư còn lại**, **Tổng đã chi**, **Hạn mức quỹ tháng** kèm phần trăm tiến độ.
* Cảnh báo trạng thái tự động: Đổi màu xanh ngọc (`Đang hoạt động`) hoặc màu đỏ nổi bật (`Vượt quỹ`).
* Nút ẩn/hiện số dư bảo mật (`•••••••• ₫`).
* Hộp thoại **"Thiết lập ngân sách"** nhanh (`BudgetEditorDialog`) với các chip gợi ý 1 chạm (`2.000.000 ₫`, `3.000.000 ₫`, `5.000.000 ₫`, `10.000.000 ₫`).

### 📊 2.4 Trực quan hóa dữ liệu bằng Canvas (`CustomPainter`)
* **Biểu đồ Donut phân bổ danh mục (`SpendingDonutChart`)**:
  * Vẽ trực tiếp 100% bằng Flutter Canvas API, không phụ thuộc thư viện đồ họa thứ ba.
  * Hoạt ảnh chuyển động mượt mà với `AnimationController`.
  * Hỗ trợ chạm chọn (touch interactive) từng lát danh mục để xem số tiền và tỷ lệ phần trăm chi tiêu trong tháng.
* **Biểu đồ cột chi tiêu tuần này (`WeeklyBarChart`)**:
  * Hiển thị 7 cột đại diện cho các thứ trong tuần (`T2` – `CN`).
  * Tự động neo mốc thời gian tuần thực tế (`05/10 – 11/10`) theo `DateTime.now()`.
  * Nhãn số tiền trên đầu cột được rút gọn tinh tế chuẩn ngân hàng (`50k`, `150k`, `1.5tr`), không bị tràn chữ trên màn hình nhỏ.

### 🧾 2.5 Hóa đơn điện tử số & Điều hướng tiện lợi (`ExpenseDetailView`)
* Phiếu xác nhận giao dịch số chính thức sau khi lưu: Huy hiệu `GIAO DỊCH HOÀN TẤT`, số tiền trừ âm nổi bật, mã giao dịch TXN định danh, hình thức thanh toán và ảnh chụp chứng từ gốc.
* Tích hợp 2 nút điều hướng kích thước lớn ở chân phiếu: **"Về trang chủ"** và **"Xem danh sách giao dịch"**.

### 🌓 2.6 Thiết kế thích ứng & Đa chủ đề (Multi-Theme)
* Bảng màu chuẩn FinTech: Xanh ngọc Emerald (`#10B981`) & Nền đen Midnight Obsidian (`#0F172A`).
* Hỗ trợ đầy đủ **Giao diện Tối (Dark Mode)** và **Giao diện Sáng (Light Mode)**.
* Bản địa hóa 100% ngôn ngữ tiếng Việt tự nhiên, phù hợp nghiệp vụ thủ quỹ và sinh viên.
* Thiết kế thích ứng không lỗi tràn khung (`RenderFlex overflow`) ngay cả trên màn hình siêu hẹp (320dp).

---

## 3. Công nghệ sử dụng

| Phân hệ | Công nghệ / Thư viện | Vai trò |
|---|---|---|
| **Framework** | Flutter 3.47.6 / Dart 3.13.5 | Nền tảng phát triển ứng dụng di động đa nền tảng |
| **State Management** | Flutter Riverpod 2.6.1 | Quản lý trạng thái phân tán, Dependency Injection Type-Safe |
| **Navigation** | GoRouter 14.8.1 | Điều hướng dạng khai báo (Declarative Routing) |
| **OCR Engine** | Google ML Kit Text Recognition 0.15.0 | Nhận dạng chữ viết trên ảnh On-Device (Offline 100%) |
| **Camera & Image** | Camera 0.11.3, Image Picker 1.2.1 | Điều khiển phần cứng camera, flash, thư viện ảnh |
| **Database** | Sqflite 2.4.2, Path Provider 2.1.5 | Cơ sở dữ liệu SQLite cục bộ, lưu trữ đường dẫn ảnh |
| **Key-Value Store** | Shared Preferences 2.5.4 | Lưu trữ cấu hình theme và hạn mức ngân sách tháng |
| **Data Visualization**| Flutter Canvas API (`CustomPainter`) | Vẽ biểu đồ Donut và biểu đồ cột tuần hiệu năng cao |

---

## 4. Kiến trúc ứng dụng

ReceiptFlow được xây dựng theo mô hình **Clean Architecture kết hợp MVVM**:

```
┌────────────────────────────────────────────────────────┐
│               TẦNG TRÌNH DIỄN (UI / VIEW)               │
│   DashboardView │ ExpensesView │ ScanReceiptView │ ...  │
└───────────────────────────┬────────────────────────────┘
                            │ Lắng nghe state
                            ▼
┌────────────────────────────────────────────────────────┐
│               VIEWMODEL (STATE NOTIFIER)               │
│  DashboardViewModel │ ExpensesViewModel │ ...          │
└───────────────────────────┬────────────────────────────┘
                            │ Thực thi nghiệp vụ
                            ▼
┌────────────────────────────────────────────────────────┐
│            TẦNG NGHIỆP VỤ (DOMAIN USE CASE)            │
│  • ParseReceiptUseCase (Regex Heuristics bóc tách)    │
│  • AggregateExpensesUseCase (Thống kê tuần & tháng)    │
│  • ExpenseRepository (Giao diện trừu tượng)            │
└───────────────────────────┬────────────────────────────┘
                            │ Triển khai dữ liệu
                            ▼
┌────────────────────────────────────────────────────────┐
│            TẦNG DỮ LIỆU & DỊCH VỤ (DATA LAYER)         │
│  • ExpenseRepositoryImpl (SQLite <-> Domain Entity)    │
│  • SqliteDatabaseService (Quản lý receipt_flow.db)     │
│  • MlkitOcrService (Nhận diện văn bản ML Kit)          │
│  • ReceiptCameraService & ReceiptStorageService        │
│  • BudgetStorageService (SharedPreferences)            │
└────────────────────────────────────────────────────────┘
```

---

## 5. Cấu trúc thư mục

```
receipt_flow/
├── android/                         # Cấu hình dự án Android Native
├── ios/                             # Cấu hình dự án iOS Native
├── docs/                            # Tài liệu kiến trúc, database, OCR, UI design
│   ├── architecture.md
│   ├── database.md
│   ├── ocr-pipeline.md
│   └── ui-design.md
├── lib/
│   ├── main.dart                    # Điểm khởi chạy ứng dụng (main entry point)
│   ├── app/
│   │   ├── app.dart                 # Cấu hình MaterialApp, Theme & Router
│   │   ├── providers/               # Composition Root: Khởi tạo Riverpod providers
│   │   └── router/app_router.dart   # Định nghĩa cây điều hướng GoRouter
│   ├── core/
│   │   ├── errors/                  # Định nghĩa AppException & Failure
│   │   └── theme/                   # Tokens: AppColors, AppRadius, AppSpacing, AppTheme
│   ├── data/
│   │   ├── models/                  # ExpenseModel ánh xạ SQLite Map <-> Entity
│   │   ├── repositories/            # Triển khai ExpenseRepository & ReceiptRepository
│   │   └── services/                # Dịch vụ Camera, SQLite, ML Kit OCR, File Storage
│   ├── domain/
│   │   ├── models/                  # Expense, ExpenseCategory, ParsedReceipt
│   │   ├── repositories/            # Interfaces của Repository
│   │   ├── use_cases/               # AggregateExpensesUseCase, ParseReceiptUseCase
│   │   └── utils/money_parser.dart  # Thuật toán chuẩn hóa tiền tệ Việt Nam
│   └── ui/
│       ├── core/widgets/            # BankHeroCard, BudgetEditorDialog, ExpenseCard,...
│       └── features/
│           ├── dashboard/           # Màn hình Trang chủ & Thẻ Quỹ
│           ├── expenses/            # Màn hình Giao dịch, Thêm/Sửa, Hóa đơn điện tử
│           ├── reports/             # Màn hình Thống kê & Biểu đồ Canvas
│           ├── scan_receipt/        # Màn hình Quét Camera & Xác nhận bóc tách OCR
│           └── settings/            # Màn hình Cài đặt & Bảo mật
├── test/                            # Bộ kiểm thử Unit Test & Widget Test (16 tests)
│   ├── domain/                      # Test bóc tách OCR, parse tiền tệ, tính tuần
│   └── widget/                      # Test UI, chống tràn viền 320dp, luồng xác nhận
├── pubspec.yaml                     # Khai báo thư viện & tài nguyên
└── Mini-Project-3-Report.md         # Báo cáo kỹ thuật chính thức theo mẫu VKU
```

---

## 6. Hướng dẫn cài đặt & Khởi chạy

### 6.1 Yêu cầu môi trường (Prerequisites)
* **Flutter SDK**: Phiên bản `>= 3.24.0` (Khuyên dùng `3.47.6` hoặc mới nhất).
* **Dart SDK**: Phiên bản `>= 3.5.0`.
* **Android SDK**: `Platform 34` hoặc `36` (Android Studio đã cấu hình).
* **Thiết bị chạy**: Khuyên dùng thiết bị Android/iOS vật lý (hoặc máy ảo Android Emulator có camera/webcam).

### 6.2 Các bước cài đặt

```sh
# 1. Clone mã nguồn từ GitHub
git clone https://github.com/duckwt1/receipt_flow.git
cd receipt_flow

# 2. Tải các gói thư viện phụ thuộc
flutter pub get

# 3. Kiểm tra chất lượng mã nguồn (phải đạt 0 lỗi)
flutter analyze

# 4. Chạy toàn bộ bộ kiểm thử tự động
flutter test

# 5. Khởi chạy ứng dụng trên thiết bị đang kết nối
flutter run
```

### 6.3 Hướng dẫn đóng gói file APK Release
Để cài đặt trực tiếp lên điện thoại Android cá nhân:

```sh
flutter build apk --release
```
*File APK cài đặt sẽ được tạo tại thư mục:* `build/app/outputs/flutter-apk/app-release.apk`.

---

## 7. Hướng dẫn sử dụng chi tiết

### 📌 Bước 1: Thiết lập ngân sách tháng
1. Tại Trang chủ, nhấn vào nút **"Đặt ngân sách"** trên thẻ xanh lá đầu màn hình (hoặc vào tab **Cài đặt** ➔ **Hạn mức ngân sách tháng**).
2. Chọn nhanh một trong các chip gợi ý (`2.000.000 ₫`, `3.000.000 ₫`, `5.000.000 ₫`, `10.000.000 ₫`) hoặc tự nhập số tiền quỹ của bạn.
3. Bấm **"Lưu ngân sách"** — thẻ Hero sẽ ngay lập tức tính toán số dư còn lại và thanh tiến độ chi tiêu.

### 📌 Bước 2: Quét hóa đơn tự động bằng Camera
1. Bấm nút **"Quét hóa đơn"** tại phím tắt trang chủ hoặc biểu tượng camera.
2. Căn chỉnh hóa đơn giấy vào giữa khung kính ngắm HUD màu xanh ngọc (bật đèn flash nếu chụp trong điều kiện thiếu sáng).
3. Nhấn nút chụp tròn hoặc bấm nút thư viện ảnh ở góc trái để chọn ảnh hóa đơn đã có.
4. Ứng dụng sẽ tự động phân tích và chuyển sang màn hình **"Kiểm tra hóa đơn"**.

### 📌 Bước 3: Xác nhận bóc tách OCR & Lưu chi tiêu
1. Màn hình hiển thị ảnh chụp hóa đơn và các trường thông tin bóc tách tự động: Nơi thanh toán, Số tiền, Ngày giao dịch, Danh mục.
2. Kiểm tra các huy hiệu độ tin cậy (`Độ tin cậy cao`, `Độ tin cậy thấp — vui lòng kiểm tra lại`). Bạn có thể chỉnh sửa bất kỳ thông tin nào nếu muốn.
3. Bấm **"Lưu chi tiêu"**:
   * Ứng dụng hiển thị thông báo *"Lưu chi tiêu thành công!"*.
   * Chuyển đến màn hình **Hóa đơn điện tử** với chứng từ xác nhận chính thức.
   * Tại đây, bạn có thể bấm nút **"Về trang chủ"** để quay lại hoặc **"Xem danh sách giao dịch"**.

### 📌 Bước 4: Xem thống kê & Biểu đồ chi tiêu
1. Chuyển sang tab **"Thống kê"** ở thanh điều hướng dưới đáy.
2. Dùng mũi tên trái/phải để chọn tháng cần xem báo cáo.
3. Xem **Biểu đồ Donut phân bổ danh mục**: Chạm vào từng lát màu để xem chi tiết số tiền và tỷ lệ phần trăm theo danh mục.
4. Xem **Biểu đồ cột chi tiêu tuần này**: Xem mức chi tiêu trực quan của 7 ngày trong tuần (`T2` – `CN`) với số tiền rút gọn chuẩn ngân hàng (`50k`, `150k`).

---

## 8. Kiểm thử tự động (Test Suite)

Dự án áp dụng phương pháp kiểm thử tự động toàn diện với **16/16 bài test** đạt chuẩn 100%:

```sh
flutter test
```

### Kết quả đầu ra kiểm thử:
```text
00:00 +0: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/aggregate_expenses_use_case_test.dart: aggregates monthly and category totals
00:00 +1: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/aggregate_expenses_use_case_test.dart: aggregates current Monday-to-Sunday spending
00:00 +2: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/aggregate_expenses_use_case_test.dart: aggregates historical month week by latest expense in that month
00:00 +3: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/parse_receipt_use_case_test.dart: money parsing normalizes user-entered currency values with locale separators
00:00 +4: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/parse_receipt_use_case_test.dart: money parsing supports Vietnamese and international thousands separators
00:00 +5: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/parse_receipt_use_case_test.dart: money parsing prefers an amount near total keywords over a larger item amount
00:00 +6: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/parse_receipt_use_case_test.dart: parses a valid date and rejects impossible dates
00:00 +7: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/domain/parse_receipt_use_case_test.dart: selects an uppercase merchant line near the top
00:00 +8: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget/receipt_review_view_test.dart: review shows editable OCR values and a low confidence prompt
00:01 +9: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget_test.dart: dashboard shows its empty state when there are no expenses
00:01 +10: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget/receipt_review_view_test.dart: ExpenseEditorView does not overflow on narrow 320dp screen
00:01 +11: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget/receipt_review_view_test.dart: ExpenseDetailView provides Về trang chủ navigation button
00:01 +12: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget_test.dart: expense list shows its empty state
00:01 +13: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget_test.dart: dashboard shows a recovery action when loading fails
00:01 +14: D:/WorkSpace/DaNenTang/mini_3/receipt_flow/test/widget_test.dart: tapping set budget opens dialog and updates monthly budget
00:01 +15: All tests passed!
```

---

## 9. Thông tin tác giả

* **Sinh viên thực hiện:** Trần Quang Việt
* **Mã số sinh viên (MSSV):** 23IT311
* **Lớp:** 23JIT
* **Khoa:** Khoa Khoa học Máy tính
* **Trường:** Trường Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU), Đại học Đà Nẵng
* **Giảng viên hướng dẫn:** TS. Nguyễn Thanh Tuấn
* **Báo cáo kỹ thuật chi tiết:** [Mini-Project-3-Report.md](Mini-Project-3-Report.md)
* **Kho lưu trữ GitHub:** [https://github.com/duckwt1/receipt_flow.git](https://github.com/duckwt1/receipt_flow.git)
