---
title: React+ts的环境配置
date: 2021-1-19 23:57:26
tags:
---

一次React+ts的项目配置
<!--more-->

 `yarn add react react-dom -S`
但是要用 babel-loader 对文件进行进行处理，webpack 识别不了 jsx 语法
`yarn add babel-loader @babel/core @babel/preset-react -D`
根目录创建`.babelrc`文件

```js
{
  "presets": ["@babel/preset-react"]
}
```

在 webpack 配置文件加上

```js
rules: [
  {
    test: /\.(tsx?|js)$/,
    loader: "babel-loader",
    options: { cacheDirectory: true },
    exclude: /node_modules/,
  },
];
```

# ts

使用 `@babel/preset-typescript` 来对 ts 的支持 `yarn add @babel/preset-typescript -D`
然后修改`.babelrc`，把`@babel/preset-typescript` 添加上去

```js
// presets的执行顺序是从后到前的
{
  "presets": ["@babel/preset-react", "@babel/preset-typescript"]
}
```

这时候修改 webpack 配置文件

```js
// 添加
resolve: {
    extensions: ['.tsx', '.ts', '.js', '.json'],
  },
```

这时候 start 就可以看到结果了。

添加 React 类型声明`yarn add @types/react @types/react-dom -D`

使用`npx tsc --init`来生成`tsconfig.json`文件

- 编译指定的文件
- 定义的编译的类型

```js
{
  "compilerOptions": {
    // 基本配置
    "target": "ES5",                          // 编译成哪个版本的 es
    "module": "ESNext",                       // 指定生成哪个模块系统代码
    "lib": ["dom", "dom.iterable", "esnext"], // 编译过程中需要引入的库文件的列表
    "allowJs": true,                          // 允许编译 js 文件
    "jsx": "react",                           // 在 .tsx 文件里支持 JSX
    "isolatedModules": true,
    "strict": true,                           // 启用所有严格类型检查选项

    // 模块解析选项
    "moduleResolution": "node",               // 指定模块解析策略
    "esModuleInterop": true,                  // 支持 CommonJS 和 ES 模块之间的互操作性
    "resolveJsonModule": true,                // 支持导入 json 模块
    "baseUrl": "./",                          // 根路径
    "paths": {																// 路径映射，与 baseUrl 关联
      "Src/*": ["src/*"],
      "Components/*": ["src/components/*"],
      "Utils/*": ["src/utils/*"]
    },

    // 实验性选项
    "experimentalDecorators": true,           // 启用实验性的ES装饰器
    "emitDecoratorMetadata": true,            // 给源码里的装饰器声明加上设计类型元数据

    // 其他选项
    "forceConsistentCasingInFileNames": true, // 禁止对同一个文件的不一致的引用
    "skipLibCheck": true,                     // 忽略所有的声明文件（ *.d.ts）的类型检查
    "allowSyntheticDefaultImports": true,     // 允许从没有设置默认导出的模块中默认导入
    "noEmit": true														// 只想使用tsc的类型检查作为函数时（当其他工具（例如Babel实际编译）时）使用它
  },
  "exclude": ["node_modules"]
}
```

# 文件层级

如果文件的层级过于深可以使用`eslint-import-resolver-typescript` `yarn add eslint-import-resolver-typescript`
然后修改`.eslintrc.js`文件和 webpack 配置中的 resolve.alias 添加映射规则

```js
settings: {
  'import/resolver': {
    node: {
      extensions: ['.tsx', '.ts', '.js', '.json'],
    },
    typescript: {},
  },
},

// webpack
resolve: {
alias: {
      Src: resolve(PROJECT_PATH, './src'),
      Components: resolve(PROJECT_PATH, './src/components'),
      Utils: resolve(PROJECT_PATH, './src/utils'),
    },
}
```
- 这里，如果你新添加了路径的话，你要去`tsconfig.json`里面`paths`添加新路径

# @babel/plugin-transform-runtime

如果使用到了 Promise 或者.includes 这些新特性，这些是没有办法转成 ES5 语法的，这时候需要把新特性的注入到打包后的文件中
`yarn add @babel/preset-env @babel/plugin-transform-runtime -D`
`yarn add @babel/runtime-corejs3 -S`
修改`.babelrc`文件

```js
{
  "presets": [
    [
      "@babel/preset-env",
      {
        // 防止babel将任何模块类型都转译成CommonJS类型，导致tree-shaking失效问题
        "modules": false
      }
    ],
    "@babel/preset-react",
    "@babel/preset-typescript"
  ],
  "plungins": [
    [
      "@babel/plugin-transform-runtime",
      {
        "corejs": {
          "version": 3,
          "proposals": true
        },
        "useESModules": true
      }
    ]
  ]
}
```

然后就出现了版本问题...查了好久换了几个版本还是出错

# 公共环境优化

打包公共静态资源，用`copy-webpack-plugin` `yarn add copy-webpack-plugin -D`
修改 webpack 配置

```js
const CopyPlugin = require("copy-webpack-plugin");

plugins: [
  new CopyPlugin({
    patterns: [
      {
        context: resolve(PROJECT_PATH, "./public"),
        from: "*",
        to: resolve(PROJECT_PATH, "./dist"),
        toType: "dir",
      },
    ],
  }),
];
```

> 特别需要注意一定要设置`cache: false` 不然你代码修改后刷新页面，HTML 不会引入任何打包出来的 JS 文件

# 显示编译进度

怀疑在偷懒，还增加了回车键的使用量，`webpackbar` `yarn add webpackbar -D`
在 webpack 中添加

```js
const WebpackBar = require("webpackbar");

plugins: [
  // 其它 plugin...
  new WebpackBar({
    name: isDev ? "正在启动" : "正在打包",
    color: "#fa8c16",
  }),
];
```

# 编译时 ts 的类型检查

编辑器中已经红色下划线了，但是还是能编译的，这就变成了 any ts 了`fork-ts-checker-webpack-plugin`来提示错误
打包或者编译的时候提示错误，安装`yarn add fork-ts-checker-webpack-plugin -D`
在 webpack 中添加

```js
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

plugins: [
  // 其它 plugin...
  new ForkTsCheckerWebpackPlugin({
    typescript: {
      configFile: resolve(PROJECT_PATH, "./tsconfig.json"),
    },
  }),
];
```

# 二次编译速度

`hard-source-webpack-plugin` 加快二次编译速度，`yarn add hard-source-webpack-plugin`

```js
const HardSourceWebpackPlugin = require("hard-source-webpack-plugin");

plugins: [
  // 其它 plugin...
  new HardSourceWebpackPlugin(),
];
```

# external 减少打包体积

引入的第三方包太多了，打包的文件就会越来越大，每次进入页面的时候很可能就会出现白屏。使用 CDN 链接的形式把包剥离出去。
webpack 配置

```js
plugins: [
    // 其它 plugin...
  ],
  externals: {
    react: 'React',
    'react-dom': 'ReactDOM',
  },
```

在 index.html 中添加链接

```html
<script
  crossorigin
  src="https://unpkg.com/react@16.13.1/umd/react.production.min.js"
></script>
<script
  crossorigin
  src="https://unpkg.com/react-dom@16.13.1/umd/react-dom.production.min.js"
></script>
```

优势

> http 缓存，浏览器的缓存策略，之后进入页面不需要重新下载`react`和`react-dom`
> 还有就是 webpack 的编译时间减少了

但是如果别人使用你的项目，就要下载对应的版本包了，因为依赖没有打进最后输入的包了面

# 抽离公共代码

懒加载，把第三方依赖打出来独立的 chunk，webpack4 默认开启这个功能
但是第三方包也打出来就要在 webpack 中配置

```js
module.exports = {
	// other...
  externals: {//...},
  optimization: {
    splitChunks: {
      chunks: 'all',
      name: true,
    },
  },
}
```

# 热更新

大一点的项目每次修改一点代码那打包时间。
新增`webpack.HotModuleReplacementPlugin`插件

```js
const webpack = require('webpack')

module.exports = merge(common, {
  devServer: {//...},
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
  ]
})
```

ts 会报错，需要安装`yarn add @types/webpack-env -D`

# 跨域

建一个文件写入接口信息

```js
const proxySettings = {
  // 接口代理1
  "/api/": {
    target: "http://198.168.111.111:3001",
    changeOrigin: true,
  },
  // 接口代理2
  "/api-2/": {
    target: "http://198.168.111.111:3002",
    changeOrigin: true,
    pathRewrite: {
      "^/api-2": "",
    },
  },
  // .....
};

module.exports = proxySettings;

// 然后在webpack dev中；引入
module.exports = merge(common, {
  devServer: {
    //...
    proxy: { ...proxySetting },
  },
});
```

# css 样式抽离

上面抽离公共代码把 css 样式都打包今年了 js 文件，这样文件就会越来越大
借助`mini-css-extract-plugin`来抽离 css `yarn add mini-css-extract-plugin -D`

```js
// 在webpack中修改
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const getCssLoaders = (importLoaders) => [
  isDev ? "style-loader" : MiniCssExtractPlugin.loader,
  // ....
];

plugins: [
  // 其它 plugin...
  !isDev &&
    new MiniCssExtractPlugin({
      filename: "css/[name].[contenthash:8].css",
      chunkFilename: "css/[name].[contenthash:8].css",
      ignoreOrder: false,
    }),
];
```

# 去除无用样式

`purgecss-webpack-plugin` 来去除无用的样式

```js
// webpack prod
const { resolve } = require("path");
const glob = require("glob");
const PurgeCSSPlugin = require("purgecss-webpack-plugin");
const { PROJECT_PATH } = require("../constants");

plugins: [
    new PurgeCSSPlugin({
      paths: glob.sync(`${resolve(PROJECT_PATH, './src')}/**/*.{tsx,scss,less,css}`, { nodir: true }),
    }),
  ],
```

# 压缩 js 和 css

webpack4 中的 js 代码压缩 `yarn add terser-webpack-plugin -D`

```js
// webpack 中 optimization
module.exports = {
	// other...
  externals: {//...},
  optimization: {
    minimize: !isDev, // 默认是true，判断如果是生产环境就开启压缩
    minimizer: [
      !isDev && new TerserPlugin({
        extractComments: false, // 去除所有注解，除了特殊标记注解
        terserOptions: {
          compress: { pure_funcs: ['console.log'] }, // 想要去除的函数，这里就去除console.log
        }
      })
    ].filter(Boolean),
    splitChunks: {//...},
  },
}

// css压缩
module.exports = {
  optimization: {
    minimizer: [
      // terser
      !isDev && new OptimizeCssAssetsPlugin()
    ].filter(Boolean),
  },
}
```

# tree-shaking

webpack 内置的打包优化，在生产环境下，打包后把`import`引入未使用的代码去除

# 打包分析

查看打出的包都有那些具体多大`yarn add webpack-bundle-analyzer -D`

```js
const webpack = require("webpack");

module.exports = merge(common, {
  plugins: [
    // ...
    new BundleAnalyzerPlugin({
      analyzerMode: "server", // 开一个本地服务查看报告
      analyzerHost: "127.0.0.1", // host 设置
      analyzerPort: 8888, // 端口号设置
    }),
  ],
});
```
- 最后在这里记录一个问题
就是`react-touter-dom`使用了`browserHistory`然后跳转页面后刷新页面就没了。然后webpack的解释

> When using the HTML5 History API, the index.html page will likely have to be served in place of any
> 404 responses. Enable devServer.historyApiFallback by setting it to true:

```js
// 把historyApiFallback打开就好了
devServer: {
    historyApiFallback: true,
  },
```
