const path = require('path');
const TerserPlugin = require("terser-webpack-plugin");

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
  devServer: {
    static: {
      directory: path.resolve(__dirname, ""),
    },
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
    minimizer: [new TerserPlugin()],
  },
};
module.exports = config;
