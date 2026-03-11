# 🔧 FIREBASE THANH TOÁN - HƯỚNG DẪN KHẮC PHỤC SỰ CỐ

## ✅ ĐÃ ĐƯỢC SỬA

1. **OrderService mới** (`lib/services/order_service.dart`)
   - Tách logic thanh toán khỏi UI
   - Thêm 8 bước xác thực trước khi tạo đơn
   - Xử lý lỗi chi tiết cho từng trường hợp

2. **checkout_screen.dart được cập nhật**
   - Dùng OrderService thay vì gọi Firebase trực tiếp
   - Thêm kiểm tra user login, giỏ hàng không trống, địa chỉ hợp lệ
   - Hiển thị lỗi cụ thể (network, Firebase, user...)

3. **Dialog thành công được cải thiện**
   - Hiển thị mã đơn hàng để tracking

---

## 🔍 CHECKLIST FIREBASE - CẦN XÁC NHẬN NGAY

### 1️⃣ **Cloud Firestore Rules** (CRITICAL)
```
Vào: Firebase Console → Firestore Database → Rules
```

**✅ RULE ĐÚNG cho phép tạo orders:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to create orders
    match /orders/{orderId} {
      allow create: if request.auth != null;
      allow read, update: if request.auth.uid == resource.data.userId;
    }

    // Allow users to write to their own notifications
    match /users/{userId}/notifications/{doc=**} {
      allow write: if request.auth.uid == userId;
      allow read: if request.auth.uid == userId;
    }

    // Allow users to read/write their own addresses
    match /users/{userId}/addresses/{doc=**} {
      allow read, write: if request.auth.uid == userId;
    }

    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**❌ KHÔNG ĐƯỢC (Sẽ bị từ chối):**
- Firestore Rules setting `allow read, write: if false;` → **SỬA NGAY**
- Rules cho phép anonymous write → **CẤM**

---

### 2️⃣ **Kiểm tra kết nối Firebase**
```
📱 Chạy app → Mở DevTools (Flutter)
🔍 Kiểm tra console logs xem có error không:
  - "Failed to initialize Firebase"
  - "Permission denied" 
  - "Quota exceeded"
```

**🛠️ Nếu thấy lỗi:**
```bash
# Chạy trong terminal (Android)
flutter clean
flutter pub get
flutter run
```

---

### 3️⃣ **Collections cần tồn tại trên Firestore**

```
📋 CẦN CÓ NHỮNG COLLECTION NÀY:

✅ /orders
   - Collection Rule: Cho phép tạo với `userId` = current user

✅ /users/{userId}/addresses
   - Sub-collection: Các địa chỉ của user

✅ /users/{userId}/notifications
   - Sub-collection: Thông báo đơn hàng

✅ /users
   - Collection: Lưu thông tin user (tùy chọn)
```

**🔧 Cách thêm Collection:**
1. Firebase Console → Firestore → `+ Create collection`
2. Nhập tên: `orders`, `users`
3. Thêm document mẫu với các field

---

### 4️⃣ **Kiểm tra Authentication Enable**

```
Firebase Console → Authentication → Sign-in method
```

**✅ CẦN BẬT:**
- [ ] Email/Password
- [ ] Phone Number (nếu dùng OTP)

**NẾUBACKGROUND KHÁC:**
- [ ] Google
- [ ] Facebook

---

## 🧪 TEST THANH TOÁN BƯỚC-BƯỚC

### Test 1: Kiểm tra User Login
```dart
// Mở DevTools và kiểm tra:
print('Current User: ${AuthService().currentUser}');
// Nếu in ra `null` → USER CHƯA ĐĂNG NHẬP
```

### Test 2: Kiểm tra Firestore Connection
```
Firebase Console → Firestore → Tạo document test:
{
  "testField": "value",
  "timestamp": (server timestamp)
}
Nếu lưu được → Connection OK ✅
```

### Test 3: Test Tạo Đơn Hàng
```
1. Đăng nhập App
2. Thêm sản phẩm vào giỏ
3. Chọn địa chỉ giao hàng
4. Chọn phương thức thanh toán
5. Nhấn "XÁC NHẬN ĐẶT HÀNG"
6. Nếu lỗi → Kiểm tra message chi tiết
7. Vào Firebase Console → Collections /orders → Xem có document mới không
```

---

## ❌ COMMON ERRORS & FIX

| Lỗi | Nguyên Nhân | Cách Fix |
|-----|------------|---------|
| `Permission denied` | Rules chưa cho phép | Cập nhật Rules như bên trên |
| `User chưa đăng nhập` | currentUser = null | Đăng nhập trước khi order |
| `Giỏ hàng trống` | items.isEmpty | Thêm sản phẩm vào giỏ |
| `Lỗi kết nối network` | Không có internet/Firebase down | Kiểm tra internet, thử lại |
| `CORS error` | Firestore CORS setting | Yêu cầu Backend setup CORS |

---

## 📊 MONITORING ORDERS

Sau khi fix, kiểm tra:
```
Firebase Console → Firestore → Collections:
  
  /orders
   └─ orderDoc1 {
       userId: "user123"
       orderDate: timestamp
       status: "Processing"
       paymentDetail: { totalAmount: 123000 }
       items: [...]
       shippingAddress: {...}
   }
```

Nếu collection có data → **THANH TOÁN HOẠT ĐỘNG!** ✅

---

## 🚀 NEXT STEPS

1. **Verify Rules** - Cập nhật Firestore Rules theo template trên
2. **Test Login** - Đảm bảo user đã authenticated
3. **Test Order** - Tạo đơn hàng test
4. **Check Logs** - Mở DevTools xem console output
5. **Monitor Firestore** - Xem data được lưu vào collection `/orders`

---

## 📞 LIÊN HỆ HỖ TRỢ

Nếu vẫn lỗi sau khi fix:
1. **Chia sẻ error message cụ thể** từ DevTools
2. **Screenshot Firebase Rules hiện tại**
3. **Screenshot Firestore Collections structure**
4. **Xác nhận user đã login**

