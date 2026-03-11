# 📜 EBONY FURNITURE - AI DEVELOPMENT RULES (OPTIMIZED)

## 🎨 1. PHONG CÁCH THIẾT KẾ (DESIGN SYSTEM)
- **Concept:** Luxury, Minimalist, Handcrafted Excellence.
- **Bảng màu:** `ebonyDark` (#1A1410), `ebonyMedium` (#2D2318), `woodAccent` (#A88860), `background` (#FAF8F5).
- **Ràng buộc:** Bo góc 15-30px, Shadow cực nhẹ (opacity 0.02-0.05), Typography IN HOA cho tiêu đề.

## ⚙️ 2. KIẾN TRÚC DỮ LIỆU (HYBRID FIREBASE)
- **Cloud Firestore:** `products`, `users`, `orders` (Lưu trữ bền vững).
- **Realtime Database:** `live_views`, `notifications` (Tốc độ cao).

## 🛠️ 3. QUY TẮC CODE & PHÂN BỔ (PROJECT STRUCTURE)
- **Cấu trúc:** `lib/models/`, `lib/services/`, `lib/providers/`, `lib/screens/`, `lib/widgets/`, `lib/theme/`.
- **Quy trình logic:** Định nghĩa dữ liệu (Model) -> Xử lý trạng thái (Provider) -> Hiển thị (Screen/Detail).
- **An toàn dữ liệu:** Ép kiểu `.toDouble()` cho giá tiền, xử lý Null-safety (`?? ''`, `?? 0`).
- **Navigation:** Dùng `pushAndRemoveUntil` sau tác vụ quan trọng (thanh toán/đăng nhập).

## 🔄 4. QUY TẮC VẬN HÀNH (STRICT RULES)
- **Tập trung mục tiêu:** CHỈ chỉnh sửa các file người dùng yêu cầu trực tiếp. Không tự ý sửa lại các module đã hoàn thành (Checkout, Address, Voucher) trừ khi có lỗi biên dịch liên quan.
- **Phân tích Checklist:** Nhắc lại yêu cầu dưới dạng Checklist trước khi code.
- **Báo cáo tiến độ:** Tóm tắt ngắn gọn "Đã làm gì" và "Cần làm gì tiếp theo". Không lặp lại các tính năng đã hoạt động ổn định.
- **Xác nhận Model:** Chỉ cung cấp code Model mới khi có sự thay đổi cấu trúc Database trên Firebase Console.
- **Xử lý lỗi:** Gọi Firebase luôn trong `try-catch` và hiển thị `SnackBar` chuẩn Ebony.
- **Tránh trùng lặp:** Không gửi lại toàn bộ mã nguồn của một file nếu chỉ thay đổi một đoạn nhỏ (ưu tiên giải thích hoặc sửa đúng chỗ).
## Quy tắc Cấu trúc Thư mục (Directory Structure)
* Code theo chuẩn Feature-first / Screen-first. Tính năng nào hiển thị ở màn hình nào thì BẮT BUỘC phải đặt file code (.dart) vào trong thư mục của màn hình đó.
* Ví dụ: Tính năng Search (Tìm kiếm) nằm ở Home thì đặt tại `lib/screens/home/` hoặc `lib/screens/home/widgets/`.
* Tuyệt đối KHÔNG vứt file tính năng riêng lẻ ra ngoài thư mục gốc `screens` hoặc nhét bừa vào thư mục `widgets` chung.

## Quy tắc Quản lý Database & Collection
* TUYỆT ĐỐI KHÔNG tự ý sinh thêm Collection mới trên Firestore mà không báo cáo.
* Nếu tính năng mới cần đọc/ghi vào một Collection chưa từng có, BẮT BUỘC phải dừng lại, báo cáo tên Collection và cấu trúc Document (các fields) để xin phép trước khi code.
* Không được dùng fake data (dữ liệu giả) bọc cứng trong UI, mọi dữ liệu động phải gọi qua Firebase.