const router = require('express').Router();
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const DocGia = require('../models/DocGia');
const auth = require('../middleware/auth');

router.use(auth);
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const isDup = (e) => e && e.code === 11000;

router.get('/', async (req, res, next) => {
  try {
    const q = (req.query.q || '').trim();
    const filter = q
      ? { $or: [{ email: new RegExp(escapeRe(q), 'i') }, { hoten: new RegExp(escapeRe(q), 'i') }] }
      : {};
    const sort = req.query.sort === 'newest' ? { _id: -1 } : { hoten: 1 };
    const data = await DocGia.find(filter).sort(sort).collation({ locale: 'vi' });
    res.json({ data, total: data.length });
  } catch (e) { next(e); }
});

router.get('/stats', async (req, res, next) => {
  try {
    const [total, withImage, newest] = await Promise.all([
      DocGia.countDocuments(),
      DocGia.countDocuments({ hinhanh: { $nin: ['', null] } }),
      DocGia.find().sort({ _id: -1 }).limit(5),
    ]);
    res.json({ total, withImage, withoutImage: total - withImage, newest });
  } catch (e) { next(e); }
});

router.param('id', (req, res, next, id) => {
  if (!mongoose.isValidObjectId(id)) return res.status(400).json({ message: 'ID không hợp lệ' });
  next();
});

router.get('/:id', async (req, res, next) => {
  try {
    const u = await DocGia.findById(req.params.id);
    if (!u) return res.status(404).json({ message: 'Không tìm thấy độc giả' });
    res.json(u);
  } catch (e) { next(e); }
});

router.post('/', async (req, res, next) => {
  try {
    const { email, matkhau, hoten, hinhanh } = req.body || {};
    if (!email || !EMAIL_RE.test(String(email).trim())) return res.status(400).json({ message: 'Email không hợp lệ' });
    if (!matkhau || String(matkhau).length < 6) return res.status(400).json({ message: 'Mật khẩu phải có ít nhất 6 ký tự' });
    if (!hoten || !String(hoten).trim()) return res.status(400).json({ message: 'Họ tên không được để trống' });
    const u = await DocGia.create({
      email, hoten, hinhanh: hinhanh || '',
      matkhau: await bcrypt.hash(String(matkhau), 10),
    });
    res.status(201).json(u);
  } catch (e) {
    if (isDup(e)) return res.status(409).json({ message: 'Email đã tồn tại' });
    next(e);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const u = await DocGia.findById(req.params.id);
    if (!u) return res.status(404).json({ message: 'Không tìm thấy độc giả' });
    const { email, matkhau, hoten, hinhanh } = req.body || {};
    if (email !== undefined) {
      if (!EMAIL_RE.test(String(email).trim())) return res.status(400).json({ message: 'Email không hợp lệ' });
      u.email = email;
    }
    if (hoten !== undefined) {
      if (!String(hoten).trim()) return res.status(400).json({ message: 'Họ tên không được để trống' });
      u.hoten = hoten;
    }
    if (hinhanh !== undefined) u.hinhanh = hinhanh || '';
    if (matkhau) {
      if (String(matkhau).length < 6) return res.status(400).json({ message: 'Mật khẩu phải có ít nhất 6 ký tự' });
      u.matkhau = await bcrypt.hash(String(matkhau), 10);
    }
    await u.save();
    res.json(u);
  } catch (e) {
    if (isDup(e)) return res.status(409).json({ message: 'Email đã tồn tại' });
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    if (req.params.id === req.userId) return res.status(400).json({ message: 'Không thể xóa chính tài khoản đang đăng nhập' });
    const u = await DocGia.findByIdAndDelete(req.params.id);
    if (!u) return res.status(404).json({ message: 'Không tìm thấy độc giả' });
    res.json({ message: 'Đã xóa độc giả' });
  } catch (e) { next(e); }
});

module.exports = router;
