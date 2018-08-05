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
    ]
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
