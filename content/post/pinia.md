---
title: "Pinia"
date: 2022-08-12T10:25:52+08:00
draft: false
---

pinia一些笔记。
<!--more-->

State、Getters、Action、plugins

## state

一个简单的store
```js
import { defineStore } from "pinia";
export const catStore = defineStore("cat", {
    state: () => {
        return {
            color: "yellow",
            weight: 10
            age: 1
        }
    },
})

// 使用
// 直接使用ES6解构能得到值 但是丢失响应式，用storeToRefs
const cat = catStore()
const { color, age } = storeToRefs(cat)

// 改变store
cat.age++

// 改变多条
catStore.$patch({
    age: cat.age + 1,
    weight: cat.weight + 10
})

// 重置状态
cat.$reset()

// 新增新对象？中文文档上说是设置新对象来替换store状态
// You cannot exactly replace the state of a store as that would break reactivity. 
// You can however patch it:
store.$state = { hobby: "sleep" }
```

## Getters
这个相当于vue的`computed`
```js
export const useStore = defineStore('main', {
  state: () => ({
    counter: 0,
  }),
  
  getters: {
    // 会自动推断类型
    doubleCount: (state) => state.counter * 2,
    // 用this 自己设置类型
    doublePlusOne(): number {
        return this.counter * 2 + 1
    },
  },
  
})
// 直接使用Getters
useStore.doubleCount

// 访问其他getter
doubleCount: (state) => state.counter * 2,
// return * 2 + 1
doublePlusOne(): number {
    return this.doubleCount + 1
},

// 可以通过返回一个函数去接收参数,但是这时候不会在进行缓存
getUserById: (state) => {
    return (userId) => state.users.find((user) => user.id === userId)
},
useStore.getUserById(1)
// 改成
getActiveUserById(state) {
    const activeUsers = state.users.filter((user) => user.active)
    return (userId) => activeUsers.find((user) => user.id === userId)
},
```

## Actions 
`actions`相当于`vuex`的`methods`，但是可以进行异步操作
```js
actions: {
    changeAge() {
        this.age++
    }
    async getUser() {
        try {
            this.user = await apiUser()
        } catch(error) {}
    }
}
// 使用
store.getUser()
```
## plugins
插件可以做以下操作

- 向 Store 添加新属性
- 定义 Store 时添加新选项
- 为 Store 添加新方法
- 包装现有方法
- 更改甚至取消操作
- 实现本地存储等副作用
- 仅适用于特定 Store

`pinia.use()`添加插件

为所有的`Store`添加静态属性
```js
function SecretPiniaPlugin() {
    return { secret: 'the cake is a lie' }
}
const pinia = createPinia()
pinia.use(SecretPiniaPlugin)
```

待续...
