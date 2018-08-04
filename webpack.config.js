const path = require('path');

const IS_NW = false; //TODO

const config = {
  context: path.join(__dirname, 'source'),
  entry: [
    './index.coffee',
  ],
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'skele2d.js',
    // library: 'skele2d', // TODO?
    library: '', libraryTarget: 'commonjs2' // https://github.com/webpack/webpack/issues/2030#issuecomment-232886608
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
  // TODO: web, not node? specify build target somewhere?
  node: {
    fs: 'empty',
    path: 'empty',
  },

  // avoiding name-mangling for entity classes
  // TODO: re-enable minification, without name mangling
  // or avoid the specific name mangling somehow,
  // or stop using function.name
  optimization: {
    minimize: false,
  },
};
module.exports = config;
