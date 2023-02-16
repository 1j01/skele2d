const path = require('path');

const config = {
  context: path.join(__dirname, 'source'),
  entry: [
    './main.coffee',
  ],
  output: {
    path: path.join(__dirname, 'build'),
    filename: 'bundle.js',
    publicPath: '/build/',
    hashFunction: 'sha256',
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
  optimization: {
    minimizer: [
    ],
  },
};
module.exports = config;
