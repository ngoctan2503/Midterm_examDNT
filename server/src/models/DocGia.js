const mongoose = require('mongoose');
const schema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    matkhau: { type: String, required: true },
    hoten: { type: String, required: true, trim: true },
    hinhanh: { type: String, default: '' },
  },
  {
    versionKey: false,
    collection: 'docgia',
    toJSON: {
      transform: (doc, ret) => {
        delete ret.matkhau;
        return ret;
      },
    },
  }
);
module.exports = mongoose.model('DocGia', schema);
