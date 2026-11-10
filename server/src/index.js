const express = require('express');
const cors = require('cors');
const { PORT } = require('./config');
const connectDB = require('./db');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/', (req, res) => res.json({ status: 'ok', app: 'LibraCard', author: '23IT.EB089 - Đặng Ngọc Tân' }));
app.use('/api/auth', require('./routes/auth'));
app.use('/api/docgia', require('./routes/docgia'));

app.use((req, res) => res.status(404).json({ message: 'Không tìm thấy đường dẫn' }));
app.use((err, req, res, next) => {
  console.error(err);
  if (err.type === 'entity.parse.failed') return res.status(400).json({ message: 'JSON không hợp lệ' });
  if (err.type === 'entity.too.large') return res.status(413).json({ message: 'Dữ liệu quá lớn' });
  if (err.name === 'ValidationError') return res.status(400).json({ message: err.message });
  res.status(500).json({ message: 'Lỗi máy chủ' });
});

connectDB()
  .then(() => app.listen(PORT, '0.0.0.0', () => console.log(`Server running at http://0.0.0.0:${PORT}`)))
  .catch((e) => { console.error('Mongo connect error:', e.message); process.exit(1); });
