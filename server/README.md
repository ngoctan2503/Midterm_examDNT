# LibraCard Server - Quản lý độc giả thư viện

Tác giả: 23IT.EB089 - Đặng Ngọc Tân

REST API (Node.js/Express + MongoDB/Mongoose). Thủ thư đăng nhập để cấp thẻ và quản lý độc giả.

CSDL: `thuvien_docgia`, collection `docgia`. Mỗi document chỉ có đúng 5 trường: `_id`, `email`, `matkhau` (bcrypt), `hoten`, `hinhanh` (data URI base64). "Mã thẻ" được suy ra từ `_id` ở phía ứng dụng, không lưu trong CSDL.

## Cài đặt và chạy
```
npm install
npm run seed     # nạp dữ liệu mẫu (thuthu@thuvien.vn / thuthu123)
npm start        # chạy server cổng 3000 (npm run dev để dùng nodemon)
npm run export   # xuất ../database/docgia.json
npm run import   # nạp lại từ ../database/docgia.json
```
Yêu cầu MongoDB tại `mongodb://127.0.0.1:27017`. Cấu hình trong `.env`.

## Endpoints
- GET `/` : health check -> {status, app, author}
- POST `/api/auth/login` {email, matkhau} -> {token, user}
- GET `/api/auth/me`
- PUT `/api/auth/change-password` {matkhauCu, matkhauMoi}
- GET `/api/docgia?q=&sort=newest` -> {data, total}
- GET `/api/docgia/stats` -> {total, withImage, withoutImage, newest}
- GET `/api/docgia/:id`
- POST `/api/docgia` {email, matkhau, hoten, hinhanh}
- PUT `/api/docgia/:id` (matkhau để trống thì giữ nguyên)
- DELETE `/api/docgia/:id` (không xóa chính tài khoản đang đăng nhập)

Các route trừ `/` và `/api/auth/login` cần header `Authorization: Bearer <token>`.

## Tài khoản demo
- Thủ thư: `thuthu@thuvien.vn` / `thuthu123`
- Độc giả mẫu: mật khẩu `123456`
