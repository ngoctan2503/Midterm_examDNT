const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { MONGO_URI } = require('../src/config');

(async () => {
  await mongoose.connect(MONGO_URI);
  const docs = await mongoose.connection.collection('docgia').find({}).sort({ _id: 1 }).toArray();
  const out = docs.map((d) => ({ ...d, _id: { $oid: d._id.toString() } }));
  const dir = path.join(__dirname, '..', '..', 'database');
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, 'docgia.json'), JSON.stringify(out, null, 2), 'utf8');
  console.log('Exported', out.length, 'docgia to', path.join(dir, 'docgia.json'));
  await mongoose.disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
