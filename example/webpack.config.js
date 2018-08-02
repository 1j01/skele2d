const path = require('path');

const IS_NW = false; //TODO

const config = {
  context: path.join(__dirname, 'source'),
  entry: [
    './main.coffee',
  ],
  output: {
    path: path.join(__dirname, 'build'),
    filename: 'bundle.js',
    publicPath: '/build/',
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
    ]
  },
  // TODO: web? specify build target somewhere?
  node: {
    fs: 'empty'
  },
  // resolve: {
  //   alias: {
  //     fs: IS_NW ? 'fs' : 'empty-module',
  //     path: IS_NW ? 'path' : 'empty-module',
  //   }
  // },

  // avoiding name-mangling for entity classes
  // TODO: re-enable minification, without name mangling
  // or avoid the specific name mangling somehow,
  // or stop using function.name
  optimization: {
    minimize: false,
  },
};
module.exports = config;
