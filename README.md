# LibraCard — Quản lý độc giả thư viện (Flutter · Node.js · MongoDB)

> **Đề thi giữa kỳ – Lập trình đa nền tảng**
> Sinh viên: **Đặng Ngọc Tân** — MSSV: **23IT.EB089**

LibraCard là phân hệ dành cho **thủ thư (admin)**: cấp thẻ thư viện có ảnh cho độc giả, xem, cập nhật và thu hồi thẻ. Cùng một mã nguồn Flutter chạy trên **Web** và **Android**, dữ liệu lưu trong **MongoDB** qua REST API Node.js/Express.

## CSDL: chỉ gồm 4 trường

Database `thuvien_docgia`, collection `docgia`:

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `email` | String | duy nhất (unique index), chuyển về chữ thường |
| `matkhau` | String | mã hóa **bcrypt** trước khi lưu |
| `hoten` | String | bắt buộc |
| `hinhanh` | String | ảnh thẻ 3×4 dạng *data URI base64* (đã nén) |

Ngoài 4 trường trên chỉ có `_id` do MongoDB tự sinh; đã tắt `__v` và không dùng timestamps. "Mã thẻ" (`TV-XXXXXXXX`) hiển thị trên app được **tính từ `_id`**, không lưu thành trường riêng.
File CSDL nộp kèm: [`database/docgia.json`](database/docgia.json), theo định dạng `mongoexport --jsonArray`.

## Chức năng
- **Đăng nhập thủ thư** (JWT, ghi nhớ phiên, tự đăng xuất khi token hết hạn).
- **Tổng quan**: số độc giả, số đã có hoặc chưa có ảnh thẻ, tỉ lệ hoàn thiện ảnh thẻ, độc giả mới đăng ký.
- **Danh sách độc giả**:
  - Tìm kiếm realtime theo họ tên hoặc email.
  - Lọc theo Tất cả / Có ảnh thẻ / Chưa có ảnh.
  - Sắp xếp A–Z theo tên kiểu tiếng Việt, hoặc Mới nhất.
  - Web hiển thị dạng bảng, mobile hiển thị dạng thẻ.
- **Cấp thẻ mới / Cập nhật**:
  - Chọn ảnh thẻ từ thư viện (Web và Android) hoặc **chụp bằng camera** (Android).
  - Xem trước thẻ thư viện ngay khi nhập.
- **Thẻ thư viện**: thẻ điện tử có ảnh, mã thẻ và mã vạch; sao chép ID.
- **Thu hồi thẻ (xóa)** có hộp thoại xác nhận, vuốt để xóa trên mobile, không cho xóa chính mình.
- **Tài khoản thủ thư**: đổi mật khẩu, chế độ tối, đăng xuất.

## Cấu trúc thư mục
```
app/        Flutter app (web + android)
server/     REST API Node.js/Express + Mongoose
database/   docgia.json – file CSDL xuất từ MongoDB
docs/       Báo cáo (docx, pdf) + ảnh minh họa
```

## Cách chạy

**Yêu cầu:** Flutter 3.x, Node.js 18 trở lên, MongoDB 7/8 (bản cài đặt hoặc bản zip portable).

```bash
# 1) MongoDB
start-mongodb.bat                 # hoặc: mongod --dbpath server/data/db

# 2) API server (cổng 3000)
cd server
npm install
npm run import                    # nạp dữ liệu từ database/docgia.json (hoặc: npm run seed)
npm start

# 3) Flutter app
cd app
flutter pub get
flutter run -d chrome             # Web
flutter run -d emulator-5554      # Android emulator (API: http://10.0.2.2:3000)
```

**Tài khoản thủ thư demo:** `thuthu@thuvien.vn` / `thuthu123`. Các độc giả mẫu dùng mật khẩu `123456`.

### Lệnh cài thư viện đã dùng
```bash
# Server
npm i express mongoose bcryptjs jsonwebtoken cors dotenv
npm i -D nodemon
# Flutter
flutter pub add http image_picker shared_preferences google_fonts flutter_animate intl flutter_svg
```

## API
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/auth/login` | Đăng nhập thủ thư → `{token, user}` |
| GET | `/api/auth/me` | Thông tin thủ thư hiện tại |
| PUT | `/api/auth/change-password` | Đổi mật khẩu |
| GET | `/api/docgia?q=&sort=newest` | Danh sách và tìm kiếm độc giả |
| GET | `/api/docgia/stats` | Thống kê |
| GET | `/api/docgia/:id` | Chi tiết |
| POST | `/api/docgia` | Cấp thẻ mới (thêm độc giả) |
| PUT | `/api/docgia/:id` | Cập nhật (bỏ trống `matkhau` = giữ nguyên) |
| DELETE | `/api/docgia/:id` | Thu hồi thẻ (xóa độc giả) |

---
© 23IT.EB089 - Đặng Ngọc Tân
