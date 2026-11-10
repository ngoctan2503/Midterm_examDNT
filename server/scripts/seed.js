const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const { MONGO_URI } = require('../src/config');
const DocGia = require('../src/models/DocGia');

const strip = (s) => s.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D');

// Anh the 3x4 (300x400) dang SVG: nen mau, hinh nguoi don gian, chu cai dau o duoi
function avatar(name, c1, c2) {
  const words = strip(name.replace(/\(.*?\)/g, '')).trim().split(/\s+/);
  const ini = (words.length > 1 ? words[0][0] + words[words.length - 1][0] : words[0][0]).toUpperCase();
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="300" height="400" viewBox="0 0 300 400"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${c1}"/><stop offset="1" stop-color="${c2}"/></linearGradient></defs><rect width="300" height="400" fill="url(#g)"/><circle cx="150" cy="140" r="52" fill="#ffffff" fill-opacity="0.85"/><path d="M50 340 C50 255 100 215 150 215 C200 215 250 255 250 340 L250 400 L50 400 Z" fill="#ffffff" fill-opacity="0.85"/><rect x="0" y="318" width="300" height="82" fill="#000000" fill-opacity="0.18"/><text x="150" y="376" font-family="Arial, Helvetica, sans-serif" font-size="56" font-weight="bold" fill="#ffffff" text-anchor="middle">${ini}</text></svg>`;
  return 'data:image/svg+xml;base64,' + Buffer.from(svg).toString('base64');
}

const list = [
  ['thuthu@thuvien.vn', 'thuthu123', 'Đặng Ngọc Tân (Thủ thư)', '#0f766e', '#10b981'],
  ['buiminhkhoa@gmail.com', '123456', 'Bùi Minh Khoa', '#0d9488', '#34d399'],
  ['dothaonhi@gmail.com', '123456', 'Đỗ Thảo Nhi', '#e11d48', '#fb7185'],
  ['ngogiahuy@gmail.com', '123456', 'Ngô Gia Huy', '#0284c7', '#38bdf8'],
  ['lythanhmai@gmail.com', '123456', 'Lý Thanh Mai', '#d97706', '#fbbf24'],
  ['trinhquocbao@gmail.com', '123456', 'Trịnh Quốc Bảo', null, null],
  ['phanngocanh@gmail.com', '123456', 'Phan Ngọc Ánh', '#059669', '#2dd4bf'],
];

(async () => {
  await mongoose.connect(MONGO_URI);
  await DocGia.deleteMany({});
  await DocGia.syncIndexes();
  for (const [email, pw, hoten, c1, c2] of list) {
    await DocGia.create({
      email, hoten,
      matkhau: await bcrypt.hash(pw, 10),
      hinhanh: c1 ? avatar(hoten, c1, c2) : '',
    });
  }
  console.log('Seeded', await DocGia.countDocuments(), 'docgia');
  await mongoose.disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
