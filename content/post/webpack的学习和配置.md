---
title: webpack的学习和配置
date: 2021-1-16 23:30:55
tags:
---

webpack 学习过程中的一些笔记
<!--more-->

# 入口(entry)和出口(output)

```js
const path = require("path");

module.exports = {
  entry: "./src/app.js", // 入口
  output: {
    path: path.resolve(__dirname, "dist"), // 出口
    filename: "my-first-webpack.bundle.js",
  },
};
```

# loader

对于模块的源代码进行转换

```js
module.exports = {
  module: {
    rules: [
      { test: /\.css$/, use: "css-loader", exclude: /node_modules/ },
      { test: /\.ts$/, use: "ts-loader", exclude: /node_modules/ },
    ],
  },
};
```

# 插件(plugins)

在 webpack 的构建中使用插件来达到你想要的构建结果，主要是解决 loader 无法实现的事情。

```js
plugins: [
  new webpack.optimize.UglifyJsPlugin(),
  new HtmlWebpackPlugin({ template: "./src/index.html" }),
];
```

# 区分开发环境和生产环境

`yarn add webpack-merge -D`

```js
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");

module.exports = merge(common, {
  mode: "development", // 开发环境。 production 生产环境
});
```

可以设置个环境变量来区分不同的环境，使用 cross-env。`yarn add cross-env -D`

```js
const isDev = process.env.NODE_ENV !== 'production'

// output设置
filename: `js/[name]${isDev ? '' : '.[hash:8]'}.js`,

// package.json ，scripts。设置开发环境或者生产环境
cross-env NODE_ENV=production webpack --config
cross-env NODE_ENV=development webpack --config
```

# 模块热替换

借助 webpack-dev-server 和 html-webpack-plugin。`yarn add webpack-dev-server html-webpack-plugin -D`

`html-webpack-plugin`把打包的 js 文件自动引入 html 里面
`webpack-dev-server`本地的 http 服务

报了个错误，查了一下是 webpack 和 webpack-dev-server 版本不不兼容导致的报错
![错误](./../images/webpack.png)
"webpack": "^5.15.0",
"webpack-cli": "^4.3.1"
"webpack-dev-server": "^3.11.2",

换版本 ok，[stack overflow](https://stackoverflow.com/questions/59611597/error-cannot-find-module-webpack-cli-bin-config-yargs)
"webpack": "4.32.2",
"webpack-cli": "3.3.0",
"webpack-dev-server": "3.11.0",

# devtool

调试错误代码

# clean-webpack-plugin

每次打包前都清除之前打包的目录`yarn add clean-webpack-plugin -D`

```js
const { CleanWebpackPlugin } = require('clean-webpack-plugin')

plugins: [
    new CleanWebpackPlugin(),
  ],
```

# css 处理

使用`style-loader`和`css-loader` `yarn add style-loader css-loader -D`

```js
module: {
  rules: [
    {
      test: /\.css$/,
      use: [
        "style-loader",
        {
          loader: "css-loader",
          options: {
            modules: false, // 默认就是 false, 若要开启，可在官网具体查看可配置项
            sourceMap: isDev, // 开启后与 devtool 设置一致, 开发环境开启，生产环境关闭
            importLoaders: 0, // 指定在 CSS loader 处理前使用的 laoder 数量
          },
        },
      ],
    },
  ];
}
```

- sass
  需要`node-sass`和`sass-loader` `yarn add node-sass sass-loader -D`

# PostCSS

对 css 的处理 `yarn add postcss-loader postcss-flexbugs-fixes postcss-preset-env autoprefixer postcss-normalize -D`

> postcss-flexbugs-fixes 修复 flex 布局的  
> postcss-preset-env 兼容  
> postcss-normalize 从 browserslist 导入需要的 Normalize.css， 它是 CSS reset 的代替方案

把公共逻辑抽取出来，放到 webpack.common.js 文件中

```js
const getCssLoaders = (importLoaders) => [
  "style-loader",
  {
    loader: "css-loader",
    options: {
      modules: false,
      sourceMap: isDev,
      importLoaders,
    },
  },
  {
    loader: "postcss-loader",
    options: {
      ident: "postcss",
      plugins: [
        // 修复一些和 flex 布局相关的 bug
        require("postcss-flexbugs-fixes"),
        require("postcss-preset-env")({
          autoprefixer: {
            grid: true,
            flexbox: "no-2009",
          },
          stage: 3,
        }),
        require("postcss-normalize"),
      ],
      sourceMap: isDev,
    },
  },
];
```

这里有报了个错误，就是最新版的更改了一些 api，所以写法就不一样了。降版本。
原先的版本
"postcss-flexbugs-fixes": "^5.0.2",
"postcss-loader": "^4.1.0",
"postcss-normalize": "^9.0.0",
"postcss-preset-env": "^6.7.0",

修改后
"postcss-flexbugs-fixes": "^4.2.1",
"postcss-loader": "^3.0.0",
"postcss-normalize": "^9.0.0",
"postcss-preset-env": "^6.7.0",

最后在 package.js 指定浏览器的范围

```json
{
  "browserslist": [">0.2%", "not dead", "ie >= 9", "not op_mini all"]
}
```

然后就已经能使用 PostCSS 了。

# 图片和字体文件

使用`file-loader`和`url-loader` `yarn add file-loader url-loader -D`
在 webpack.common.js 中添加

```js
{
        test: [/\.bmp$/, /\.gif$/, /\.jpe?g$/, /\.png$/],
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 10 * 1024,
              name: '[name].[contenthash:8].[ext]',
              outputPath: 'assets/images',
            },
          },
        ],
      },
      {
        test: /\.(ttf|woff|woff2|eot|otf)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              name: '[name].[contenthash:8].[ext]',
              outputPath: 'assets/fonts',
            },
          },
        ],
      },
```

但是在 ts 中引入图片会报错
在`src`中新建文件`typings/file.d.ts`

```ts
declare module "*.svg" {
  const path: string;
  export default path;
}

declare module "*.bmp" {
  const path: string;
  export default path;
}

declare module "*.gif" {
  const path: string;
  export default path;
}

declare module "*.jpg" {
  const path: string;
  export default path;
}

declare module "*.jpeg" {
  const path: string;
  export default path;
}

declare module "*.png" {
  const path: string;
  export default path;
}
```

webpack的配置差不多先到这里了