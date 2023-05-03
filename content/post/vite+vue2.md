---
title: "Vite+vue2"
date: 2023-05-03T09:44:22+08:00
draft: false
---

不要问我为什么用上vite还在vue2
<!--more-->

# 关于vite+vue2的一些坑和配置

## vue2 & @vitejs/plugin-vue2
初始化项目`pnpm create vite`，选择`Vanilla`，`JavaScript`

![avatar](https://raw.githubusercontent.com/pastSeagull/blog/main/img/vite-vue2.png)

这里安装`vue`和`@vitejs/plugin-vue2`，安装`vue`的时候要指定版本，不然就装`vue3`了

```js
"@vitejs/plugin-vue2": "^2.2.0",
"vue": "^2.7.0"
```

新建`src`文件，在`src`下新建`App.vue`,`main.js`
main.js修改为

```js
import Vue from "vue";
import App from "./App.vue"

new Vue({
    el: "#app",
    render: (h) => h(App)
}).$mount();

```

根目录下新建`vite.config.js`
```js
import createVuePlugin from '@vitejs/plugin-vue2'

export default {
  plugins: [createVuePlugin()]
}
```
根目录下的index.html
```html
<script type="module" src="/main.js"></script>
<!--改为-->
<script type="module" src="/src/main.js"></script>
```
删掉`counter.js` `javascript.svg` `style.css`

![avatar](https://raw.githubusercontent.com/pastSeagull/blog/main/img/vite-vue2-first.png)

这时候`pnpm run dev`就可以看到效果了

## element-ui & legacy
安装`element-ui` `@vitejs/plugin-legacy` `unplugin-vue-components`

按需引入`element-ui`需要安装`unplugin-vue-components`

main.js导入css`import 'element-ui/lib/theme-chalk/index.css';`

vite.config.js改成这样
```js
import createVuePlugin from '@vitejs/plugin-vue2'
import Components from 'unplugin-vue-components/vite'
import { ElementUiResolver } from 'unplugin-vue-components/resolvers'
import legacy from '@vitejs/plugin-legacy'

export default {
    plugins: [
        createVuePlugin(),
        Components({
            resolvers: [ElementUiResolver()],
        }),
        legacy({
            targets: ['defaults', 'not ie < 9'],
        }),
    ],
    build: {
        rollupOptions: {
            output: {
                manualChunks: {
                    'element-ui': ['element-ui'],
                },
            },
        },
    },
}
```

## 坑 & 一些配置

### 坑
说一下我遇到的坑
刚开始用的是`vite-plugin-vue2`这时候用element-ui部分组件无法使用显示
比如说`table`组件根本显示不出来，找到个issues解决了，把`vite-plugin-vue2`换成`@vitejs/plugin-vue2`
https://github.com/ElemeFE/element/issues/21968

### 配置
下面的一些配置就看个人喜好了，当然vue2.7也支持写`Composition API`，
本来我的vue版本是2.5的，因为某些业务原因。现在也是2.5，只是这篇博客换上了2.7。

这里要说的是2版本有些写法，比如说`this.$message` `this.$confirm` `v-loading`这些
可以在main.js中配置
```js
import { Message, MessageBox, Loading } from "element-ui";

Vue.use(Loading.directive)
Vue.use({
    install (Vue) {
        Vue.Message = Message
        Vue.MessageBox = MessageBox
        Vue.prototype.$message = Message
        Vue.prototype.$confirm = MessageBox
    }
})
```
当然还有一些`router` `axios`这些就自行添加了


最后不要在问我为什么用vite还在用vue2，用vue2.7还不用`Composition API`
要是现在自己从头开始的项目我还是推荐什么都拉到最新的了，当然你要是需要兼容低版本的浏览器另外说。
这个项目本意是是都拉到最新的，当我用vue3写完之后我觉得没必要那么麻烦。因为这个是相当于从2迁移到3了。
这个项目只是作为另一个项目的一个小部分，一边改了 边也得改，所以还是我太懒了，为了以后好维护~~好ctrl c v~~

