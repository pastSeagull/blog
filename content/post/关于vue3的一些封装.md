---
title: "关于vue3的一些封装"
date: 2022-04-17T16:59:33+08:00
draft: true
---

## 不优雅的错误处理封装

对于在用户的操作的过程中，发生的数据的请求或者表单的提交什么的，这时候我们需要展示操作的状态。
这里我们对于这些反馈信息进行一个不优雅的封装。

比如说后台系统中最常见的就是各种`table`，这时候我们正常操作就是用一个变量来记录当前的状态。
`let listLoading = ref(false)`我们创建一个loading来记录表格是否在加载中。
然后接下来我们就不断的修改`listLoading` `true` & `false`。
看了一下花裤衩，`getList`改成`true`,请求完了就改成`false`。
这时候我们的组件越来越多，基本上每一个页面上都需要维护这个变量。
我这边就封装一个并不优雅，可能还不如各个组件各自维护的好的方法。

先简单点的话，`loading`会这样变化 `false` => `true` => `false`。
之后结果就成功或者失败。

数据的请求中，我们一般会有这几种状态，`idle`,`loading`,`error`,`success`。
```ts
interface State<T> {
    error: Error | null,
    data: T | null,
    stat: "idle" | "loading" | "error" | "success"
}
```