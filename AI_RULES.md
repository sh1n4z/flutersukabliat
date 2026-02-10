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
