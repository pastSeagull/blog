---
title: "Jest"
date: 2022-03-25T20:38:13+08:00
---

关于前端测试
<!--more-->

jest的一些基本用法
先简单使用
```js
// add.js
export const add = (x, y) => {
    return x + y
}
// add.test.js
test('add function test', () => {
    expect(add(1, 2)).toBe(3)
})
// 命令行输出
√ add function test (1 ms)

----------|---------|----------|---------|---------|-------------------
File      | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s 
----------|---------|----------|---------|---------|-------------------
All files |     100 |      100 |     100 |     100 |                   
 add.js   |     100 |      100 |     100 |     100 | 
----------|---------|----------|---------|---------|-------------------
```
好了你已经学会了jest了，接下来先写几个简单的测试用例

## testing-library

react测试库

### 测试组件
下面是一个简单的组件测试
`getByText`
```js
// app.tsx
export const App = ({ name, age }: {name: string, age: number}) => {
  return (
    <div>
        <span style={{ color: "red" }}>{name}</span>
        <span>{age}</span>
    </div>
  );
}
// app.test.tsx
describe('test App', () => {
    test('test', () => {

        let name = 'seagull'
        let age = 24

        render(<App name={name} age={age} />)

        expect(screen.getByText(name)).toBeInTheDocument() // 看是否被渲染了
        expect(screen.getByText(name)).toHaveStyle("color: red") // 是否存在样式
        expect(screen.getByText(age)).not.toHaveStyle("color: red") // 不存在样式

        expect(screen.getByText(/eagu/)).toBeInTheDocument()// 模糊匹配

        // 隐式断言
        screen.getByText(name)
        // 显式断言
        expect(screen.getByText(name)).toBeInTheDocument()

        // 还有就是看到说是用getByText来查看是否存在会报错？
        // ESLint: Use `queryBy*` queries rather than `getBy*` for checking element is NOT present(testing-library/prefer-presence-queries)
        expect(screen.getByText(/eagu/)).toBeNull()

        expect(screen.queryByText(/eagu/)).toBeNull()
    })
})
```
大概有以下的API，具体使用那个自己根据业务情况吧
- queryByText
- queryByRole
- queryByLabelText
- queryByPlaceholderText
- queryByAltText
- queryByDisplayValue
- findByText
- findByRole
- findByLabelText
- findByPlaceholderText
- findByAltText
- findByDisplayValue

#### 事件
> 模拟用户的交互


### http请求测试
这边用到了msw https://github.com/mswjs/msw

```js
// 比如说测试getUser
import { setupServer } from "msw/node"
import { rest } from "msw"

const server = setupServer()

// 测试前回调
beforeAll(() => server.listen())

// 每一次测试跑完都执行
afterEach(() => server.resetHandlers())

// 测试跑完后回调
afterAll(()=> server.close())

// 测试方法是否返回正确的数据 & 页面是否正确的渲染
describe('test http function', () => {
    test('test getUser', async() => {
        const users = {
            name: 'seagull',
            age: 17
        }
        server.use(
            rest.get(`${apiUrl}/getUser`, (req, res, ctx) => {
                return (
                    res(ctx.json(users))
                )
            })
        )
        const result = await(getUser())
        expect(result.data).toEqual(users);

        // 渲染后数据是否存在
        // 一般来说getByText来查找，不过这是异步。使用findByText来判断一个元素是否存在
        render(<User />)
        expect(await screen.findByText("seagull")).toBeInTheDocument()
    })
})
```


### 断言函数
```js
toBeDisabled
toBeEnabled
toBeEmpty
toBeEmptyDOMElement
toBeInTheDocument
toBeInvalid
toBeRequired
toBeValid
toBeVisible
toContainElement
toContainHTML
toHaveAttribute
toHaveClass
toHaveFocus
toHaveFormValues
toHaveStyle
toHaveTextContent
toHaveValue
toHaveDisplayValue
toBeChecked
toBePartiallyChecked
toHaveDescription
```

## vue-test-utils
vue的话使用的是这个库https://github.com/vuejs/vue-test-utils

- 挂载组件
```js
import { mount } from '@vue/test-utils'
import Counter from './counter'
// 用mount来挂载组件
const wrapper = mount(Counter)

// 获取组件的实例
const vm = wrapper.vm
```
官方文档的例子
```js
export default {
  template: `
    <div>
      <span class="count">{{ count }}</span>
      <button @click="increment">Increment</button>
    </div>
  `,

  data () {
    return {
      count: 0
    }
  },

  methods: {
    increment () {
      this.count++
    }
  }
}
// test

// 查找button
test('test has a button', () => {
    expect(wrapper.contains('button')).toBe(true)
})
// 模拟点击后 data里的count的值发生变化
test('test increment & count', () => {
    expect(vm.count).toBe(0)
    const button = wrapper.find('button')
    button.trigger('click')
    expect(vm.count).toBe(1)
})
```


emmmmmm，api太多了，更具体的api用法还是看官网文档吧，这边先简单使用了前端的测试。
具体的测试还是得看业务需求吧