const path = require('path');

const makeConfig = ({ minimize, esm }) => {
  return {
    context: path.join(__dirname, 'source'),
    entry: [
      './index.coffee',
    ],
    experiments: {
      outputModule: esm,
    },
    output: {
      path: path.join(__dirname, 'dist'),
      filename: `skele2d${esm ? '.esm' : ''}${minimize ? '.min' : ''}.js`,
      library: esm ? {
        type: 'module',
      } : "skele2d",
      libraryTarget: esm ? undefined : 'umd',
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
        {
          test: /\.(svg)$/i,
          type: "asset",
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
  for (const esm of [false, true]) {
    configs.push(makeConfig({ minimize, esm }));
  }
}
module.exports = configs;
