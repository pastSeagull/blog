---
title: "Setup语法糖和一些生态库"
date: 2022-04-15T10:31:01+08:00
---

前面我们了解到了vue3新增的一些东西，这里我们来看一下`setup`的语法糖。
并不完整哈，这里知识记录一些很简单的一些使用。
<!--more-->

代码片段的demo是用`vite`创建的`yarn create vite package-name`。

把`script`改成`<script setup lang="ts">`，就可以使用语法糖了。
写法上个人感觉上和React有些类似。

话说以前都是`template`在上面
首先是组件，导入进来直接使用。
```js
<script setup lang="ts">
  import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <HelloWorld />
</template>
```
然后就是变量和方法都不需要在`return`出来了。
## defineProps & defineEmits & defineExpose
看名字应该都知道是啥了
一个简单的栗子
```js
<script setup lang="ts">
import {onMounted, ref} from 'vue'
import HelloWorld from './components/HelloWorld.vue'

const emitTest = (data: number) => {
  console.log('子组件传的值', data)
}

const son = ref()
onMounted(() => {
  console.log(son.value.name)
})
</script>

<template>
  <HelloWorld ref="son" @emitTest="emitTest" msg="hello world" />
</template>
// 子组件
<script setup lang="ts">
import { ref, defineEmits, defineExpose } from 'vue'
const count = ref(0)
defineProps({
  msg: {
    type: String,
    default: ""
  }
})
const em = defineEmits(['emitTest'])
const emCount = () => {
  em("emitTest", 17)
}

const name = ref("seagull")
defineExpose({
  name
})
</script>

<template>
  <div>{{msg}}</div>
  <button @click="emCount">传值给父组件</button>
</template>
```
然后`defineProps`有这几种用法
```js
defineProps(["msg"]);
defineProps({
    msg: String
});
defineProps({
    msg:{
        type: String,
        default: ""
    }
});
defineProps:{
    msg:[String, Number]
}
```
然后有个有个包`vue-global-api`，这样直接使用`api`了。
https://github.com/antfu/vue-global-api

## vue-router@4
首先是`new Router()`变成了`createRouter()`，还有就是用`history`代替了`mode`。

```js
import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
    {
        path: '/page1',
        name: 'Page1',
        component: () => import('../components/page1.vue')
    }
]
const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router;
```
具体变化可以看一下官方文档或者下面链接

https://juejin.cn/post/7049974026650779661#heading-15

https://juejin.cn/post/6994747097899597860#heading-7

使用的话
```js
<script setup>
  import { useRouter } from 'vue-router'
  const router = useRouter()

  const goPage = () => {
    router.push({ path: '/page1'})
  }
</script>

<template>
  <span @click="goPage">go page1</span>
</template>
```
> `useRoute`和`useRouter`，类似于`$route`和`$router`
## vuex@4
```js
import { createStore } from 'vuex'

const defaultState = {
    count: 0
}

export default createStore({
    state() {
        return defaultState
    },
    mutations: {
        updataCount(state: typeof defaultState) {
            state.count++
        }
    },
    actions: {},
    getters: {}
})
```
然后我们在组件中使用的话，`useStore`相当于替代了`this.$store`。
```js
<script setup>
  import { useStore } from 'vuex'

  const store = useStore()
  console.log(store.state.count)
  const cheangeCount = () => {
    store.commit("updataCount")
  }

</script>

<template>
  <button @click="cheangeCount">{{store.state.count}}</button>
</template>
```
目前就暂时先记录这些，并不完整哈。
差不多先这样，还有很多都未曾使用或者看过，之后在开发过程中发现没写上去的之后在补了。