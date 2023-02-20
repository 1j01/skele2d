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
    hashFunction: 'xxhash64',
  },
  devServer: {
    static: {
      directory: path.resolve(__dirname, ""),
    },
  },
  resolve: {
    // Temporary workaround for https://github.com/webpack/webpack/issues/16744
    // a webpack bug where importing a library built with webpack as ESM fails.
    // I provide both "module" and "main" fields in package.json in skele2d now;
    // webpack prefers "module", which broke the build.
    mainFields: ['main', 'module'],
    // This example doesn't import any other packages, but if you do, you may
    // need to use a "fallback" field to tell webpack to use the CommonJS
    // specifically for skele2d.
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
    minimizer: [new TerserPlugin({
      terserOptions: {
        keep_classnames: true, // needed for serialization, and display in the entities bar UI
      },
    })],
  },
};
module.exports = config;
