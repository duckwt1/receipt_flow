# MINI-PROJECT SHORT TECHNICAL REPORT
**Course:** Phát triển Ứng dụng Di động Đa nền tảng (Cross-Platform Mobile App Development - VKU)  
**Mini-Project Title:** Mini-Project 3: ReceiptFlow – Ứng dụng Quét Hóa đơn & Quản lý Quỹ Sinh viên / CLB Thông minh (On-Device OCR & Banking UI/UX)  
**Student Name:** Trần Quang Việt (MSSV: 23IT311 — Lớp: 23JIT)  
**Instructor:** TS. Nguyễn Thanh Tuấn (Khoa Khoa học Máy tính, VKU)  
**Submission Date:** 08/10/2026  

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members / Student:**
  * **Trần Quang Việt** — MSSV: **23IT311** — Lớp: **23JIT** — Vai trò: Full-Stack Mobile Architect (Toàn bộ kiến trúc Clean Architecture MVVM, Tích hợp Camera & Google ML Kit OCR, Bóc tách Regex Heuristics, Cơ sở dữ liệu SQLite, Đồ họa Custom Canvas, Giao diện Ngân hàng Banking UI/UX, Bản địa hóa Tiếng Việt & Bộ kiểm thử tự động) — Đóng góp: **100%**
* **💻 GitHub Repository:** [https://github.com/duckwt1/receipt_flow.git](https://github.com/duckwt1/receipt_flow.git)
* **📦 Tech Stack & Framework:** Flutter 3.47.6 / Dart 3.13.5, Flutter Riverpod 2.6, GoRouter 14.8, Google ML Kit Text Recognition, Sqflite, Camera, CustomPainter Canvas.

---

## 2. FEATURE IMPLEMENTATION CHECKLIST

| # | Required Feature (Rubric Criteria) | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| **1** | **Camera Capture & Viewfinder Overlay** | ✅ Complete | Tích hợp camera thời gian thực với đầy đủ tính năng: Bật/tắt đèn flash, chạm lấy nét đa điểm (tap-to-focus), khung viền căn chỉnh HUD vẽ bằng CustomPaint (`_FramePainter`), tùy chọn tải ảnh từ thư viện ảnh thiết bị (`image_picker`). |
| **2** | **On-Device Text Recognition (Google ML Kit)** | ✅ Complete | Tích hợp `google_mlkit_text_recognition` chạy trực tiếp 100% On-Device trên thiết bị di động (đạt tốc độ phản hồi sub-100ms, không phụ thuộc kết nối Internet, chi phí đám mây = $0, đảm bảo tính riêng tư dữ liệu tài chính). |
| **3** | **Heuristic Regex Engine & Extraction** | ✅ Complete | Bộ giải tích Regex tùy biến bóc tách tự động: (1) Tổng số tiền (`MoneyParser`) xử lý cả dấu chấm và dấu phẩy phân tách hàng nghìn (`150.000 đ`, `150,000 VND`), thuật toán ưu tiên số nằm gần từ khóa `TỔNG CỘNG / TOTAL / THANH TOÁN`; (2) Ngày tháng giao dịch (`DD/MM/YYYY`, `DD-MM-YYYY`); (3) Tên đơn vị bán/cửa hàng in hoa. |
| **4** | **Interactive Review Screen & Confidence Badges** | ✅ Complete | Màn hình kiểm tra hóa đơn (`ReceiptReviewView`) hiển thị huy hiệu độ tin cậy trực quan (`Độ tin cậy cao`, `Độ tin cậy trung bình`, `Độ tin cậy thấp — vui lòng kiểm tra lại`), cho phép người dùng chỉnh sửa từng trường thông tin trước khi lưu chính thức vào cơ sở dữ liệu. |
| **5** | **Local Database Persistence & Image Caching** | ✅ Complete | Cơ sở dữ liệu quan hệ cục bộ SQLite (`sqflite`), lập chỉ mục (indexing) theo `expenseDate` và `category`. Lưu ảnh chứng từ độc lập trong thư mục lưu trữ ứng dụng (`app documents/receipts`) với tên ngẫu nhiên chống trùng lặp, không lưu byte nhị phân vào DB để tối ưu hiệu năng. |
| **6** | **Budget Management & Live Balance (Ngân sách)** | ✅ Complete | Thẻ Hero ngân sách phong cách ngân hàng (`BankHeroCard`) hiển thị số dư còn lại thời gian thực, thanh tiến độ chi tiêu, huy hiệu trạng thái `Đang hoạt động` / `Vượt quỹ` (đổi màu cảnh báo tự động), nút ẩn/hiện số dư bảo mật và hộp thoại thiết lập hạn mức quỹ tháng (`BudgetEditorDialog`) với các chip gợi ý nhanh (2tr, 3tr, 5tr, 10tr). |
| **7** | **Custom Canvas Visualizations (CustomPainter)** | ✅ Complete | Tự thiết kế và vẽ 100% bằng Canvas API không dùng thư viện biểu đồ bên thứ ba: (1) **Biểu đồ Donut phân bổ danh mục** (`SpendingDonutChart`) với hoạt ảnh ease-out cubic, hỗ trợ chạm chọn từng lát để xem % chi tiêu; (2) **Biểu đồ cột chi tiêu tuần** (`WeeklyBarChart`) với cột nền track, gradient màu sắc, tính chuẩn mốc tuần thực và nhãn số tiền rút gọn chuẩn ngân hàng (`150k`, `1.5tr`). |
| **8** | **Banking UI/UX & Responsive Multi-Theme** | ✅ Complete | Giao diện FinTech chuẩn ngân hàng (Palette Emerald `#10B981` & Deep Obsidian), hỗ trợ Dark/Light Theme đầy đủ, bản địa hóa 100% tiếng Việt cho thủ quỹ sinh viên & CLB, tối ưu tuyệt đối chống lỗi `RenderFlex overflow` trên màn hình siêu hẹp (320dp). Bổ sung nút "Về trang chủ" trên hóa đơn xác nhận giao dịch. |
| **9** | **Testing & Code Quality Assurance** | ✅ Complete | Đạt **16/16 Unit & Widget tests** (100% pass), bao gồm kiểm thử logic tính toán ngân sách, bóc tách Regex, phân tích tuần và chống tràn giao diện. Phân tích tĩnh `flutter analyze` đạt **0 issues**. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE

### 3.1 Sơ đồ luồng dữ liệu kiến trúc (Clean Architecture + MVVM)
ReceiptFlow áp dụng kiến trúc phân tầng phân tách độc lập giữa Tầng Trình diễn (UI/Presentation), Tầng Nghiệp vụ (Domain Core), và Tầng Dữ liệu (Data Layer):

```
┌────────────────────────────────────────────────────────────────────────┐
│                        TẦNG GIAO DIỆN (UI / VIEW)                       │
│  DashboardView │ ExpensesView │ ScanReceiptView │ ReportsView │ Settings│
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Lắng nghe trạng thái (watch/listen)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        VIEWMODEL (STATE NOTIFIER)                      │
│  DashboardViewModel │ ExpensesViewModel │ ScanReceiptViewModel │ ...    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Gọi thực thi nghiệp vụ
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        TẦNG NGHIỆP VỤ (DOMAIN USE CASE)                 │
│  • ParseReceiptUseCase (Regex Heuristics bóc tách OCR)                 │
│  • AggregateExpensesUseCase (Tổng hợp ngân sách tháng & tuần này)     │
│  • ExpenseRepository Interface (Ràng buộc hợp đồng dữ liệu trừu tượng)  │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Triển khai cụ thể (Dependency Inversion)
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        TẦNG DỮ LIỆU & DỊCH VỤ (DATA LAYER)              │
│  • ExpenseRepositoryImpl (Chuyển đổi Entity <-> Model)                 │
│  • SqliteDatabaseService (SQLite CRUD & Database Indexing)             │
│  • MlkitOcrService (Google ML Kit On-Device Text Recognition)          │
│  • ReceiptCameraService & ReceiptImagePickerService (Camera / Gallery) │
│  • BudgetStorageService (SharedPreferences lưu hạn mức ngân sách)      │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Cấu trúc điều hướng (Navigation Routing Hierarchy)
Sử dụng `GoRouter` với các đường dẫn khai báo phân cấp rõ ràng:
```
GoRouter
├── /                   (Trang chủ: Quỹ cá nhân/CLB, Thẻ Hero, Phím tắt, Danh mục, Giao dịch gần đây)
├── /expenses           (Màn hình Giao dịch: Lọc danh mục, Tìm kiếm, Lọc khoảng ngày, Danh sách chi tiêu)
│   ├── /expenses/new   (Thêm chi tiêu thủ công)
│   ├── /expenses/:id   (Hóa đơn điện tử: Chi tiết chứng từ, Mã TXN, Nút Về trang chủ & Danh sách)
│   └── /expenses/:id/edit (Chỉnh sửa khoản chi tiêu)
├── /scan               (Màn hình Quét hóa đơn: Camera Viewfinder, Bật đèn flash, Lấy nét)
│   └── /scan/review    (Kiểm tra bóc tách hóa đơn: Thẻ ảnh, Điểm tin cậy OCR, Lưu vào quỹ)
├── /reports            (Màn hình Thống kê: Bộ chọn tháng, Biểu đồ Donut, Biểu đồ cột tuần này)
└── /settings           (Cài đặt & Bảo mật: Hạn mức ngân sách, Chọn chủ đề Sáng/Tối, Thông tin hệ thống)
```

### 3.3 Cấu trúc thư mục dự án chuẩn hóa
```
lib/
├── app/
│   ├── app.dart                    # MaterialApp cấu hình Theme & Router
│   ├── providers/                  # Composition Root: Khởi tạo Riverpod providers cho Repositories & Services
│   └── router/app_router.dart      # Cấu hình GoRouter khai báo toàn bộ cây điều hướng
├── core/
│   ├── errors/                     # AppException & Failure định nghĩa lỗi hệ thống
│   └── theme/                      # Design tokens: AppColors, AppRadius, AppSpacing, AppTheme
├── data/
│   ├── models/expense_model.dart   # Data Model ánh xạ SQLite Map <-> Dart Object
│   ├── repositories/               # Triển khai ExpenseRepository & ReceiptRepository
│   └── services/                   # Các dịch vụ nền tảng:
│       ├── camera/                 # Điều khiển camera phần cứng & đèn flash
│       ├── database/               # Khởi tạo SQLite database (receipt_flow.db)
│       ├── ocr/                    # Tích hợp Google ML Kit Text Recognition
│       └── storage/                # Lưu trữ file ảnh hóa đơn & SharedPreferences ngân sách
├── domain/
│   ├── models/                     # Thực thể cốt lõi: Expense, ExpenseCategory, ParsedReceipt
│   ├── repositories/               # Interfaces trừu tượng của Repository
│   ├── use_cases/                  # AggregateExpensesUseCase, ParseReceiptUseCase
│   └── utils/money_parser.dart     # Thuật toán bóc tách tiền tệ đa định dạng
└── ui/
    ├── core/widgets/               # Component dùng chung: BankHeroCard, BudgetEditorDialog, ExpenseCard,...
    └── features/
        ├── dashboard/              # View & ViewModel màn hình Trang chủ
        ├── expenses/               # View & ViewModel màn hình Giao dịch, Thêm/Sửa, Chi tiết hóa đơn
        ├── reports/                # View, ViewModel & CustomPainter biểu đồ Donut & Cột tuần
        ├── scan_receipt/           # View & ViewModel quét camera và xác nhận bóc tách OCR
        └── settings/               # View màn hình Cài đặt & Bảo mật trên thiết bị
```

---

## 4. BẰNG CHỨNG THỰC NGHIỆM & HÌNH ẢNH MINH HỌA (SCREENSHOTS) 

<a href="https://drive.google.com/file/d/1LTwUB-ftjt-856LSloJA0aCK1n0rDu6y/view?usp=sharing">
  Xem video tại đây
</a>

### 📸 Hình ảnh 1: Màn hình Trang chủ & Thẻ Quỹ Ngân sách thời gian thực (`DashboardView`)
* **Mô tả minh họa:** Thể hiện phong cách FinTech hiện đại với thẻ **Hero Ngân Sách Chi Tiêu** (`BankHeroCard`). Hiển thị số dư còn lại trực quan (`3.880.000 ₫`), thanh tiến độ chi tiêu (`Đã chi: 1.120.000 ₫ / Quỹ: 5.000.000 ₫ (22%)`), nút chuyển đổi ẩn/hiện số dư bảo mật, nút bấm nhanh *"Đặt ngân sách"*, 4 phím tắt ngân hàng tròn (`Quét hóa đơn`, `Thêm chi tiêu`, `Thống kê`, `Lịch sử`), lưới 5 danh mục quỹ và danh sách giao dịch gần đây kèm trạng thái `Thành công`.

### 📸 Hình ảnh 2: Kính ngắm Quét hóa đơn trực tiếp & HUD nhận diện (`ScanReceiptView`)
* **Mô tả minh họa:** Giao diện camera tràn màn hình tối ưu độ sáng, kính ngắm căn chỉnh hóa đơn với 4 góc HUD màu xanh ngọc vẽ bằng `_FramePainter`, banner hướng dẫn *"Căn chỉnh hóa đơn vào khung hình"*, công tắc bật/tắt đèn flash trợ sáng ban đêm, nút chuyển đổi lấy ảnh từ thư viện thiết bị và nút chụp lớn nổi bật. Hoạt ảnh xoay *"Đang phân tích hóa đơn… Đang nhận diện số tiền & nơi bán"* khi bắt đầu nhận diện.

### 📸 Hình ảnh 3: Màn hình Bóc tách & Kiểm tra độ tin cậy hóa đơn (`ReceiptReviewView`)
* **Mô tả minh họa:** Thẻ xem trước hình ảnh hóa đơn vật lý vừa chụp. Phía dưới là các trường dữ liệu do `ParseReceiptUseCase` tự động bóc tách kèm các huy hiệu điểm tin cậy trực quan: Tên đơn vị bán (`Nơi thanh toán / Đơn vị bán`), Tổng tiền (`Số tiền`), Ngày giao dịch và Dropdown chọn danh mục chi tiêu. Cho phép chỉnh sửa bất kỳ trường nào trước khi nhấn nút *"Lưu chi tiêu"*.

### 📸 Hình ảnh 4: Hóa đơn điện tử hoàn tất giao dịch & Nút trở về trang chủ (`ExpenseDetailView`)
* **Mô tả minh họa:** Phiếu xác nhận giao dịch số chính thức sau khi lưu thành công: Biểu tượng tích xanh tròn, thông báo `GIAO DỊCH HOÀN TẤT`, số tiền trừ âm màu đỏ rõ nét (`- 150.000 ₫`), đường nét đứt phân cách (dashed divider), mã giao dịch TXN định danh, hình thức thanh toán và hình ảnh hóa đơn/chứng từ đính kèm. Dưới cùng trang bị 2 nút điều hướng kích thước lớn: **"Về trang chủ"** và **"Xem danh sách giao dịch"**.

### 📸 Hình ảnh 5: Phân tích tài chính Canvas CustomPainter (`ReportsView`)
* **Mô tả minh họa:** Màn hình thống kê đa chiều: Bộ chọn tháng linh hoạt với mũi tên chuyển tháng; Thẻ tổng chi tiêu tháng lớn; **Biểu đồ Donut phân bổ danh mục** vẽ trên Canvas với hoạt ảnh mượt mà, hỗ trợ chạm chọn từng danh mục để xem % tương ứng; **Biểu đồ cột chi tiêu tuần này** (`WeeklyBarChart`) hiển thị 7 cột thứ trong tuần (T2 - CN) kèm khoảng ngày chính xác (`05/10 – 11/10`), số tiền trên đầu cột rút gọn thanh lịch (`150k`, `200k`) và bảng kê chi tiết từng danh mục.

### 📸 Hình ảnh 6: Hộp thoại thiết lập ngân sách & Cài đặt bảo mật (`SettingsView`)
* **Mô tả minh họa:** Modal thiết lập ngân sách với các chip chọn nhanh tiền triệu (`2.000.000 ₫`, `3.000.000 ₫`, `5.000.000 ₫`, `10.000.000 ₫`). Màn hình Cài đặt & Bảo mật thể hiện cam kết bảo mật On-Device cục bộ, chuyển đổi giao diện Sáng / Tối và hiển thị phiên bản công nghệ `Google ML Kit On-Device` & `Local SQLite`.

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS

### 🔴 Thách thức 1: Xử lý định dạng tiền tệ Việt Nam & Bóc tách số tiền tổng chính xác từ văn bản OCR
* **Vấn đề gặp phải:** Hóa đơn bán lẻ tại Việt Nam (Co.opmart, WinMart, Highland, nhà sách, quán ăn) có bố cục rất đa dạng: sử dụng cả dấu chấm (`150.000`) và dấu phẩy (`150,000`) để phân tách hàng nghìn, có thêm ký tự `đ`, `VND`, hoặc viết hoa/thường lẫn lộn. Nếu chỉ lấy con số lớn nhất xuất hiện trên hóa đơn sẽ dễ bị nhận diện nhầm vào số điện thoại cửa hàng, mã số thuế (MST) hoặc mã vạch sản phẩm.
* **Giải pháp kỹ thuật:** 
  1. Phát triển `MoneyParser` có khả năng chuẩn hóa chuỗi số thông minh: Phân tích cụm 3 chữ số liên tiếp sau dấu phân cách để nhận biết dấu hàng nghìn thay vì dấu thập phân.
  2. Thuật toán xếp hạng trọng số vị trí (Proximity Ranking): Quét từ khóa nhận diện tổng tiền (`TỔNG TIỀN`, `TỔNG CỘNG`, `THANH TOÁN`, `TOTAL`, `CỘNG TIỀN`). Các dòng số nằm ngay sau hoặc cùng dòng với từ khóa tổng tiền được gán trọng số ưu tiên cao nhất (confidence score 0.95), giải quyết triệt để tình trạng nhầm lẫn với số điện thoại hoặc mã số thuế.

### 🔴 Thách thức 2: Sửa lỗi biểu đồ cột tuần không hiển thị do lệch mốc thời gian (Week Anchor Bug)
* **Vấn đề gặp phải:** Khi người dùng quét và lưu hóa đơn thành công vào các ngày giữa/cuối tháng (từ ngày 5 trở đi), chuyển sang màn hình Báo cáo thì Biểu đồ cột chi tiêu tuần (`WeeklyBarChart`) hoàn toàn trống trơn (tất cả các cột đều bằng 0) mặc dù tổng chi tiêu tháng vẫn tăng.
* **Nguyên nhân cốt lõi:** Trong `AggregateExpensesUseCase`, mốc tính toán tuần bị lấy theo ngày của `referenceDate` được truyền từ ViewModel. ViewModel truyền vào tháng với ngày mặc định là mùng 1 (`day = 1`). Do đó, mốc tuần chỉ gom các hóa đơn thuộc tuần đầu tiên của tháng (chứa ngày 1). Bất kỳ hóa đơn nào phát sinh sau ngày mùng 4 đều có chỉ số khoảng cách ngày `index >= 7` và bị loại bỏ khỏi mảng 7 ngày trong tuần.
* **Giải pháp kỹ thuật:** 
  1. Tái cấu trúc logic xác định mốc tuần trong `AggregateExpensesUseCase`: Nếu tháng được chọn là tháng hiện tại, mốc tuần (`weekAnchor`) tự động neo theo thời gian thực `DateTime.now()`, tính chính xác từ Thứ Hai (T2) đến Chủ Nhật (CN) của tuần hiện tại. Nếu xem tháng trước, tự động neo vào tuần chứa hóa đơn mới nhất của tháng đó.
  2. Tính toán khoảng cách ngày chuẩn bằng UTC (`DateTime.utc`) để triệt tiêu sai số múi giờ và DST.
  3. Bổ sung `weekStart` và `weekEnd` vào thực thể `SpendingSummary` để hiển thị phạm vi ngày tuần minh bạch trên tiêu đề biểu đồ (`05/10 – 11/10`).

### 🔴 Thách thức 3: Trải nghiệm điều hướng sau khi quét hóa đơn & Chống tràn chữ trên Canvas
* **Vấn đề gặp phải:** 
  1. Sau khi người dùng quét và lưu hóa đơn, màn hình chuyển sang Hóa đơn điện tử (`ExpenseDetailView`) nhưng thiếu nút quay về Trang chủ rõ ràng, buộc người dùng phải tìm cách thoát.
  2. Trên biểu đồ cột Canvas, khi số tiền chi tiêu lớn (ví dụ `1.500.000 ₫` hoặc `150.000 ₫`), chuỗi ký tự dài bị đè lên nhau giữa các cột liền kề trên màn hình điện thoại hẹp (320dp - 360dp).
* **Giải pháp kỹ thuật:**
  1. **Nâng cấp điều hướng Hóa đơn điện tử:** Thêm nút hành động kích thước lớn **"Về trang chủ"** (`FilledButton`) và **"Xem danh sách giao dịch"** (`OutlinedButton`) ngay bên dưới phiếu hóa đơn, đồng thời thiết lập icon Back trên `AppBar` điều hướng an toàn về `/`.
  2. **Rút gọn nhãn số tiền phong cách FinTech:** Xây dựng hàm `_formatCompact(double value)` trong `WeeklyBarPainter`: Các khoản chi hàng nghìn được rút gọn tự động dạng `k` (ví dụ `150k`), hàng triệu rút gọn dạng `tr` (ví dụ `1.5tr`). Giải pháp này giúp số tiền hiển thị cực kỳ sắc nét, vừa vặn trên đầu mỗi cột mà không bao giờ bị tràn viền hay đè chữ.
