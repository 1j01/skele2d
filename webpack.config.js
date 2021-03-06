const path = require('path');

const config = {
  context: path.join(__dirname, 'source'),
  entry: [
    './index.coffee',
  ],
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'skele2d.js',
    library: 'skele2d',
    libraryTarget: 'commonjs2',
    libraryExport: 'default',
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ],
      },
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
    ],
  },
};
module.exports = config;
