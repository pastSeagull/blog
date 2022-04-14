---
title: "React18"
date: 2022-04-01T22:47:02+08:00
draft: true
---

关于react18的一些学习

https://github.com/facebook/react/blob/main/CHANGELOG.md


创建项目 https://blog.logrocket.com/how-to-use-typescript-with-react-18-alpha/

# New Features

## useId
> useId is a new hook for generating unique IDs on both the client and server, while avoiding hydration mismatches. 
> It is primarily useful for component libraries integrating with accessibility APIs that require unique IDs. 
> This solves an issue that already exists in React 17 and below, 
> but it’s even more important in React 18 because of how the new streaming server renderer delivers HTML out-of-order.

主要是解决SSR，客户端和服务端上生成唯一的ID，避免两个生成的ID不匹配
```js
// nest
// Error: Hydration failed because the initial UI does not match what was rendered on the server.
let id = Math.random();
export const Test = () => {
    return <div>{id}</div>
}
```
`dehydrate`生成的id和`hydrate`阶段生成的id不匹配
关于ssr脱水和注水 https://segmentfault.com/a/1190000038336185

## startTransition
> startTransition and useTransition let you mark some state updates as not urgent. 
> Other state updates are considered urgent by default. 
> React will allow urgent state updates (for example, updating a text input) to interrupt non-urgent state updates (for example, rendering a list of search results).

像我们在web应用中，对于UI的更新先后顺序进行区分，将优先级较低的更新放在后面进行更行

将一些状态更新记为不紧急，状态更新在默认情况下都是紧急的。

在`startTransition`的回调中都是非紧急处理，当如果出现了紧急的更新，则回调中的更新会被中断。
直到没有其他紧急操作之后在去执行更新
像下面的demo，优先更新value
```js
const App = () => {
  const [content, setContent] = useState("");
  const [value, setInputValue] = useState("");

  return (
    <div>
      <div>
        <input
          value={value}
          onChange={(e) => {
            setInputValue(e.target.value);
            // 使用startTransition
            startTransition(() => {
                setContent(e.target.value);
            })
            
          }}
        />
      </div>
      <div>优先级高: {value}</div>
      <br />
      {Array.from(new Array(30000)).map((el, index) => (
        <div key={index}>{content}</div>
      ))}
    </div>
  );
}
```
然后我看到了另一个栗子





## useDeferredValue
> useDeferredValue lets you defer re-rendering a non-urgent part of the tree. 
> It is similar to debouncing, but has a few advantages compared to it. 
> There is no fixed time delay, so React will attempt the deferred render right after the first render is reflected on the screen. 
> The deferred render is interruptible and doesn't block user input.

这个api让你推迟重新渲染部分
类似于防抖，但是它不会像防抖一样会有固定的延迟时间
先看看一个简单的防抖
```js
export const useDebounce = <T>(value: T, delay: number) => {
    const [debouncedValue, setDebouncedValue] = useState(value);
    useEffect(() => {
        const timeout = setTimeout(() => setDebouncedValue(value), delay);
        return () => clearTimeout(timeout);
      }, [value, delay]);
    
      return debouncedValue;
}

export const Test = () => {
    const [value, setValue] = useState("")
    const Text = useDebounce(value, 1000)
    return <div>
        <input
            value={value}
            onChange={(e) => {
                setValue(e.target.value)
            }}
        />
        <div>
            Debounce: {Text}
        </div>
    </div>
}
```