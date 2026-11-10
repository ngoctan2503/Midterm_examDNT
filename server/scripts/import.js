// Nap lai CSDL tu file ../database/docgia.json (dinh dang mongoexport --jsonArray)
// Tac gia: 23IT.EB089 - Dang Ngoc Tan
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { MONGO_URI } = require('../src/config');

(async () => {
  const file = path.join(__dirname, '..', '..', 'database', 'docgia.json');
  const raw = JSON.parse(fs.readFileSync(file, 'utf8'));
  const docs = raw.map((d) => ({
    _id: new mongoose.Types.ObjectId(d._id.$oid || d._id),
    email: d.email,
    matkhau: d.matkhau,
    hoten: d.hoten,
    hinhanh: d.hinhanh || '',
  }));
  await mongoose.connect(MONGO_URI);
  const col = mongoose.connection.collection('docgia');
  await col.deleteMany({});
  await col.insertMany(docs);
  await col.createIndex({ email: 1 }, { unique: true });
  console.log('Imported', docs.length, 'docgia from', file);
  await mongoose.disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
