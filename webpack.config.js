const path = require('path');

const makeConfig = ({ minimize }) => {
  return {
    context: path.join(__dirname, 'source'),
    entry: [
      './index.coffee',
    ],
    output: {
      path: path.join(__dirname, 'dist'),
      filename: `skele2d${minimize ? '.min' : ''}.js`,
      library: 'skele2d',
      libraryTarget: 'umd',
      libraryExport: 'default',
      hashFunction: 'xxhash64',
    },
    module: {
      rules: [
        {
          test: /\.coffee$/,
          use: ['coffee-loader'],
        },
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader']
        },
      ],
    },
    optimization: {
      minimize,
    },
  };
};

const configs = [];
for (const minimize of [false, true]) {
  configs.push(makeConfig({ minimize }));
}
module.exports = configs;
