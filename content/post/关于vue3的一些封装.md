---
title: "关于vue3的一些封装"
date: 2022-04-17T16:59:33+08:00
draft: false
---

一个不优雅并且没啥用的封装处理。不看省掉几分钟的时间。
<!--more-->

___

2022.8.9更新
发现我之前的栗子太蠢了，写`nuxt3`的时候简单的用了一下`hook`,虽然下面这个栗子也比较蠢。
应该还能分得更细致一些。基本都是一个业务/一组功能放一个hook，import进来暴露就完事了，
然后一个文件夹就`usexxx * n`,`index.vue * 1`
不过vue3用`Composition API`还是以前的`Options API`思维的话,还不如写vue2的写法。
```ts
// api.ts
export const fetchTest = async (tab) => {
    return $fetch(`https://cnodejs.org/api/v1/topics?tab=${tab}`)
}

// utils.ts
export const useAsync = () => {
    const loading = ref(false)
    const data = ref(null)
    const error = ref(null)
    const request = (promise) => {
        if (!promise || !promise.then) {
            throw new Error("请传入promise")
        }
        loading.value = true
        return promise.then(res => {
            data.value = res.data
        }).catch(e => {
            error.value = e
        }).finally(() => {
            loading.value = false
        })
    }
    return {
        loading,
        error,
        data,
        request
    }
}
// item.ts
export const useItem = (promise) => {
    const { loading, error, data, request} = useAsync()
    onMounted(() => request(promise))
    return {
        loading,
        error,
        data,
        request
    }
}
// 使用
const { loading, error, data, request } = useItem(fetchTest(""))
```
- 或者可以这样写：
> 这里`request`这里传入`params`，然后`useAsync`传入`promise`
>
> 这样`useItem`直接使用传入`api`就行了。

好了下面这些就不用在看了

___


## 不优雅的错误处理封装

对于在用户的操作的过程中，发生的数据的请求或者表单的提交什么的，这时候我们需要展示操作的状态。
这里我们对于这些反馈信息进行一个不优雅的封装。

比如说后台系统中最常见的就是各种`table`，这时候我们正常操作就是用一个变量来记录当前的状态。
`let listLoading = ref(false)`我们创建一个loading来记录表格是否在加载中。
然后接下来我们就不断的修改`listLoading` `true` & `false`。
看了一下花裤衩，`getList`改成`true`,请求完了就改成`false`。
这时候我们的页面越来越多，基本上每一个页面上都需要维护这个变量。
我这边就封装一个并不优雅，可能还不如各个组件各自维护的好的方法。

先简单点的话，`loading`会这样变化 `false` => `true` => `false`。
之后结果就成功或者失败。

数据的请求中，我们一般会有这几种状态，`idle`,`loading`,`error`,`success`。
> 但是在vue中感觉没必要这么麻烦
```ts
type State<T> = {
    error: Error | null,
    data: T | null,
    state: "idle" | "loading" | "error" | "success"
}
```
先创建一个简单的api请求
```ts
export type List = {
    code: number,
    msg: string,
    data: data[]
}
export type data = {
    name: string,
    age: number
}

export const tableList = (): Promise<List> => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve({
                code: 200,
                msg: "ok",
                data: [
                    {
                        name: 'seagull',
                        age: 17
                    },
                    {
                        name: 'gaviota',
                        age: 21
                    }
                ]
            });
        }, 1000);
    })
}
```
use-loading.ts文件
```ts
export default <T>() => {
    let loading: Ref<boolean> = ref(false)
    let data = reactive<State<null>>({
        stat: "idle",
        data: null,
        error: null
    })
    const setSuccess = (result: any) => {
        data.stat = "success"
        data.data = result
        data.error = null
    }
    const setError = (error: Error) => {
        data.stat = "error"
        data.data = null
        data.error = error
    }
    const useAsync = (promise: Promise<T>) => {
        if (!promise || !promise.then) {
            throw new Error("请传入promise")
        }
        loading.value = true

        promise.then((res) => {
            setSuccess(res)
            loading.value = false
        })
            .catch((error: Error) => {
                loading.value = false
                setError(error)
            })

    }
    return {
        loading,
        data,
        useAsync
    }

}
```
使用
```vue
<template>
    <div>{{ loading }}</div>
    <div>{{ data }}</div>
    <button @click="getList">请求</button>
</template>
<script setup lang="ts">
    const {loading, data, useAsync} = useLoading();
    const getList = () => {
        useAsync(tableList())
    }
</script>
```
这时候我们点击请求数据的时候，可以看到`loading`和`data`状态的变化。

但是这样就会有问题，如果我们请求两个接口的话后面就会顶掉前一个的了。

然后我看到了`vue-query`, 说是实现核心来自于`react-query`。然后我也没用过。
所以回归开头，这是啥用都没有的一个封装。
或许后面可能会有轮子出来，也可能已经有很好的处理方案了，只是我不知道


