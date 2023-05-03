---
title: "useEffect&useState"
date: 2022-09-07T19:01:07+08:00
draft: false
---

接口返回时间不确定，当第二次接口返回的数据比第一次快的时候，
可能也就一些大数据量的特定接口会出现这些问题。
<!--more-->

某个业务代码，大概就是类似于select or tab切换的场景中，当你第二次点击接口的返回数据比第一次快的时候。

看下面代码，这时候我们先点击`2`在点击`1`，这时候因为2数据返回会比较慢，这时候数据就不对了。
```js
import { useEffect, useState } from 'react'

type Type = string | null

export const textPromise = (value: Type): Promise<Type> => {
  let delay = value === '2' ? 2000 : 200
  return new Promise((reject, resolve) => {
    setTimeout(() => {
      reject(value)
    }, delay)
  })
}

function App() {
  const [data, setData] = useState<Type>(null)
  const [value, setValue] = useState<Type>("1")

  useEffect(() => {
    setData(null)
    textPromise(value).then((res) => {
      setData(res)
    })
  }, [value])

  return (
    <div>
      <button onClick={() => setValue("1")}>1</button>
      <button onClick={() => setValue("2")}>2</button>
      <button onClick={() => setValue("3")}>3</button>
      <br />
      {data ?? 'loading'}
    </div>
  )
}
export default App
```
这时候大佬这样写，大概就是点击的时候记录开始和结束时间，然后用ref来更新值。
在`deps`用了`ref`作为依赖，但是`ref`没有`dispatcher`的，`ref`的更新也不会`render`

经过整理后大概是这样，实际上真正起作用的是`setValue`，水管图.jpg。

```js
function App() {
  const [value, setValue] = useState<Type>(null)
  const startTimeRef = useRef(0)

  useEffect(() => {
    console.log('useEffect', startTimeRef.current)
  }, [startTimeRef.current])

  const changeValue = (value: string) => {
    startTimeRef.current = new Date().getTime()
    setValue(value)
  }

  const printRef = () => {
    console.log(startTimeRef.current)
  }

  return (
    <>
      <button onClick={() => changeValue("1")}>1</button>
      <button onClick={() => changeValue("2")}>2</button>
      <button onClick={() => changeValue("3")}>3</button>
      <br />
      <button onClick={printRef}>print ref</button>
    </>
  )
}
```

`abortController`，但是兼容性不太好
https://developer.mozilla.org/zh-CN/docs/Web/API/AbortController/AbortController

大概就是塞个额外判定的条件判断ui的state和接口的state是对得上的

```js
useEffect(() => {
  let canceled = false
  setData(null)
  textPromise(value).then((res) => {
    if(canceled) return
      setData(res)
  })
  return () => { canceled = true }
}, [value])
```

vue也差不多，在select这种场景也可能会遇到这种问题。

```js
<script lang="ts" setup>
import { ref } from 'vue'

const value = ref('')
const data = ref<Type>(null)
const options = [
  {
    value: '1',
    label: '1',
  },
  {
    value: '2',
    label: '2',
  },
  {
    value: '3',
    label: '3',
  }
]
const changeSelect = (val: string) => {
  textPromise(val).then(res => {
    data.value = res
  })
} 

</script>
<template>
  <div>
    <el-select @change="changeSelect" v-model="value" class="m-2" placeholder="Select" size="large">
      <el-option v-for="item in options" :key="item.value" :label="item.label" :value="item.value" />
    </el-select>
    <br />
    {{data}}
  </div>
</template>
```

当然你可以设置`disabled`，第一次数据没返回就禁用
```js
const changeSelect = (val: string) => {
  data.value = null
  disabledSelect.value = true
  textPromise(val).then(res => {
    data.value = res
  }).catch(e => {}).finally(() => {
    disabledSelect.value = false
  })
}
```

## 参考

___
1. [React Docs BETA](https://beta-reactjs-org-git-effects-fbopensource.vercel.app/)
