---
title: "Vue3"
date: 2022-04-14T09:58:41+08:00
---

关于Vue3的一些笔记啥的。
<!--more-->
## 一些区别
先来看看`main.js & app.vue`写法上有什么区别吧。
`main.js`
```js
// vue2
import Vue from 'vue'
import App from './App.vue'

Vue.config.productionTip = false

new Vue({
render: h => h(App),
store,
router,
}).$mount('#app')

// vue3
import { createApp } from 'vue'
import App from './App.vue'

createApp(App).use(router).use(store).mount('#app')
```
原来的构造函数变成了链式了
然后我们在来看`app.vue`的`template`
```js
// vue2
<template>
    <div id="app">
        <img alt="Vue logo" src="./assets/logo.png">
            <HelloWorld msg="Welcome to Your Vue.js App"/>
    </div>
</template>
// vue3
<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <HelloWorld msg="Welcome to Your Vue.js App"/>
</template>
```
可以看到外层嵌套的`div`标签没了，原来的vue2只能有一个根节点，而vue3支持多根节点
> 应该是重写了Virtual DOM。
> 这篇笔记只记录一些写法和一些api，并不打算看源码得到答案啥的。

## setup
一些关于setup里的一些用法

### props context
> 接收两个参数`props` `context`
> 其中props是响应式的，所以不可以使用ES6的解析，解析会消除响应式

可以这样写`setup(){}`其中`context`里面包括了`this.$attrs, this.$slots, this.$emit`。
也可以这样写`setup(props, { attrs, slots, emit }){}`
简单的栗子
```js
<script>
export default {
  name: 'HelloWorld',
  props:{
      msg: {
          type: String
      }
  },
  setup(props, context) {
    console.log('props', props.msg) // hello world
    console.log('context', context)

    let name = 'seagull'
    function sayName() {
      console.log(name)
    }

    return {
      name,
      sayName,
    }
  }
}
</script>
```
### ref & reactive
ref

> 接受一个参数值并返回一个响应式且可改变的 ref 对象。ref 对象拥有一个指向内部值的单一属性 .value。
```js
<script>
import { ref } from 'vue'
export default {
  name: 'HelloWorld',

  setup() {
    const age = ref(17)

    function updataAge() {
      age.value++
    }

    return {
      age,
      updataAge
    }
  }
}
</script>
```
可以接收一个参数，也可以用来获取DOM节点
> 这里注意，一定要return出去，不然就获取不到。至于生命周期，下面再说。
```js
<div class="hello" ref="hello">hello</div>
setup() {
    const hello = ref(null)
    onMounted(() => {
        console.log(hello.value)
    })
    return {
        hello
    }
}
```
- reactive

reactive是使用`Props`来实现的，所以只能传入对象作为参数
```js
<div v-for="items in userList.item" :key="items.age">{{items.name}}, {{items.age}}</div>
<script>
    setup() {
        const userList = reactive({
            item: [
                {
                    name: "name1",
                    age: 17
                },
                {
                    name: "name2",
                    age: 18
                },
                {
                    name: "name3",
                    age: 19
                },
            ]
        })
    }
    return {
        userList
    }
</script>
```
### computed watch watchEffect
先看`computed`，一个回调的话默认是`get`。当然你也自定义`get`和`set`。
> 没记错的话计算属性是根据依赖进行缓存的，当依赖发生改变它才发生改变，那么问题来了，这个set有啥用。不管了先看看栗子吧
```js
<script>
import { computed, reactive } from 'vue'
export default {
  name: 'HelloWorld',

  setup() {

    const calculate = reactive({
        x: 1,
        y: 2
    })
    const result = computed({
      get: () => calculate.x + calculate.y,
      set: (val) => {
        calculate.y = val
      },
    })
    result.value = 5
    console.log(calculate) // x: 1 y: 5 
    return {
      result,
    }
  }
}
</script>
// or
const result = computed(()=> {
    // 一个回调 表示get方法
    return calculate.x + calculate.y
})
```
接下来看看`watch`
可以监听一个或者多个，如果监听多个的话返回的就是数组
这个回调有三个参数，监听值，`new & old`数据，还有`{ deep: true }`
```js
<template>
  <button @click="count++">{{count}}</button>
  <button @click="age++">{{age}}</button>
</template>

<script>
import { watch, ref } from 'vue'
export default {
  name: 'HelloWorld',

  setup() {
    let count = ref(0)
    let age = ref(17)
    watch([count, age], (newValue, oldValue) => {
      console.log('newValue', newValue)
      console.log('oldValue', oldValue)
    })
    return {
      count,
      age
    }
  }
}
</script>
```
监听reactive
这里监听`reactive`时`deep`强制是`true`，无法关闭。
> 还有就是`new & old`数据都是一样的，无法正确获取到oldValue
```js
<template>
  <button @click="info.name += '1'">{{info.name}}</button>
  <button @click="info.age++">{{info.age}}</button>

  <div v-for="(item, index) in info.catColor" :key="index">{{item}}</div>
  <button @click="updataColor">add color</button>
</template>

<script>
import { watch, reactive } from 'vue'
export default {
  name: 'HelloWorld',

  setup() {
    let info = reactive({
      name: 'seagull',
      age: 17,
      catColor: [
        'black',
        'white'
      ]
    })
    function updataColor() {
      info.catColor.push('yellow')
    }
    watch(info, (newValue, oldValue) => {
      console.log('newValue', newValue)
      console.log('oldValue', oldValue)
    })
    return {
      info,
      updataColor
    }
  }
}
</script>
// 不可以监听单个
watch(info.name, (newValue, oldValue) => {
    console.log('newValue', newValue)
    console.log('oldValue', oldValue)
})
// 这样
watch(() => info.name, (newValue, oldValue) => {
    console.log('newValue', newValue)
    console.log('oldValue', oldValue)
})
// 多个
watch([() => info.name, () => info.age], (newValue, oldValue) => {
    console.log('newValue', newValue)
    console.log('oldValue', oldValue)
})
```
还有个`watchEffect`
还是上面那个栗子，把`watch`换成了`watchEffect`
```js
watchEffect(() => {
  console.log('effect', info.age)
})
// 停止监听
const stop = watchEffect(() => {
    /* ... */
})

stop()
```
这时候刷新一下，可以看到控制已经`console`出来了，然后我们每点击增加一次`info.age`
这里都会重新打印一下。这和`watch`有啥不同。
- 首先我们不需要指定监听的属性，它会自动收集，当属性改变的时候，执行一次回调。
- watch可以获得新旧值，`watchEffect`获取不了
- 组件初始化的时候它会执行一次回调

当然你不停止监听，在组件取消挂载的时候会自动停掉的。

## 生命周期
和原来也差不多，还是分为这几个阶段
- 创建 — 在组件创建时执行
- 挂载 — DOM 被挂载时执行
- 更新 — 当响应数据被修改时执行
- 销毁 — 在元素被销毁之前立即运行

多了这几个
首先是`renderTracked`，就是DOM重新渲染的时候会调用。官网介绍是这样的
> 当虚拟 DOM 重新渲染为 triggered.Similarly 为renderTracked，接收 debugger event 作为参数。
> 此事件告诉你是什么操作触发了重新渲染，以及该操作的目标对象和键。
这时候我们改一下上面的栗子
```js
<template>
  <button @click="info.name += '1'">{{info.name}}</button>
  <button @click="info.age++">{{info.age}}</button>

  <div v-for="(item, index) in info.catColor" :key="index">{{item}}</div>
  <button @click="updataColor">add color</button>
</template>

<script>
import { reactive, onRenderTracked } from 'vue'
export default {
  name: 'HelloWorld',

  setup() {
    let info = reactive({
      name: 'seagull',
      age: 17,
      catColor: [
        'black',
        'white'
      ]
    })
    function updataColor() {
      info.catColor.push('yellow')
    }
    onRenderTracked(({ key, target, type }) => {
      console.log({ key, target, type })
      console.log("renderTracked")
    })
    return {
      info,
      updataColor
    }
  }
}
</script>
```
这时候控制台是这样的, 总共执行了6次
![avatar](https://raw.githubusercontent.com/pastSeagull/blog/main/img/onRenderTracked.png)

这时候我们点击更改`name & age`，都没有执行。当更改`catColor`的时候这个生命周期触发了。
所以说这个`catColor`总共重新渲染了四次？

还有这个`renderTriggered`和上面那个应该算是一对把。
> 当虚拟 DOM 重新渲染为 triggered.Similarly 为renderTracked，接收 debugger event 作为参数。
> 此事件告诉你是什么操作触发了重新渲染，以及该操作的目标对象和键。

在上面的栗子添加代码
```js
onRenderTriggered(({ key, target, type }) => {
  console.log('---------onRenderTriggered', { key, target, type })
})
```
这时候我们改变`name & age`都会触发这个生命周期。当我们改变`catColot`时，两个都触发了。
这两个新增的生命周期应该懂了吧。
最后在`setup(){}`里，生命周期是这样写的
- beforeCreate===>Not needed*
- created=======>Not needed*
- beforeMount ===>onBeforeMount
- mounted=======>onMounted
- beforeUpdate===>onBeforeUpdate
- updated =======>onUpdated
- beforeUnmount ==>onBeforeUnmount
- unmounted =====>onUnmounted

当然还更新了很多，具体还是看看官方文档吧。

## 参考
___
1. [vue3保姆级教程](https://juejin.cn/post/7030992475271495711#heading-31)
2. [浅谈Vue3的watchEffect用途](https://segmentfault.com/a/1190000023669309)
3. [Vue 3 生命周期完整指南](https://juejin.cn/post/6945606524987244558#heading-17)
4. [Vue3生命周期详解](https://juejin.cn/post/7020017329815683085)
