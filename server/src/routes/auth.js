const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const DocGia = require('../models/DocGia');
const auth = require('../middleware/auth');
const { JWT_SECRET } = require('../config');

router.post('/login', async (req, res, next) => {
  try {
    const { email, matkhau } = req.body || {};
    if (!email || !matkhau) return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu' });
    const user = await DocGia.findOne({ email: String(email).toLowerCase().trim() });
    if (!user || !(await bcrypt.compare(String(matkhau), user.matkhau)))
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng' });
    const token = jwt.sign({ id: user._id.toString() }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user });
  } catch (e) { next(e); }
});

router.get('/me', auth, async (req, res, next) => {
  try {
    const user = await DocGia.findById(req.userId);
    if (!user) return res.status(401).json({ message: 'Tài khoản không tồn tại' });
    res.json(user);
  } catch (e) { next(e); }
});

router.put('/change-password', auth, async (req, res, next) => {
  try {
    const { matkhauCu, matkhauMoi } = req.body || {};
    if (!matkhauCu || !matkhauMoi) return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin' });
    if (String(matkhauMoi).length < 6) return res.status(400).json({ message: 'Mật khẩu mới phải có ít nhất 6 ký tự' });
    const user = await DocGia.findById(req.userId);
    if (!user) return res.status(401).json({ message: 'Tài khoản không tồn tại' });
    if (!(await bcrypt.compare(String(matkhauCu), user.matkhau)))
      return res.status(400).json({ message: 'Mật khẩu cũ không đúng' });
    user.matkhau = await bcrypt.hash(String(matkhauMoi), 10);
    await user.save();
    res.json({ message: 'Đổi mật khẩu thành công' });
  } catch (e) { next(e); }
});

module.exports = router;
