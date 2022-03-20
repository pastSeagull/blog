---
title: "hooks"
date: 2022-03-16T10:13:16+08:00
---

hooks的一些基本用法
<!--more-->

# api
- useCallback
- useContext
- useEffect
- useLayoutEffect
- useMemo
- useReducer
- useRef
- useState

## useState
```js
// 定义count的初始状态，如果是function的话就用返回值
const [count, setCount] = useState(0)
// or
const [count, setCount] = useState(() => 0)
// 还有就是不能在Component函数中同步调用setCount
const App = () => {
    const [count, setCount] = useState(0)
    // 在同步中调用setCount
    // Too many re-renders. React limits the number of renders to prevent an infinite loop.
    setCount(count + 1) 

    return(
      <div>
        {count}
        <button onClick={() => { 
           setCount(count + 1)

           // 这里会不会即时改变
           console.log(count)
          }}
          >+</button>
      </div>
    )
}
```
如果初始值是`function`的话，`useState`的值只会在初始化的时候执行
```js
// 这边props点击+1，但是子组件的count还是没有改变
// 当然可以利用这个特点，组件重绘的时候就不用在进行useState的计算了
// setCount传函数，传函数的好处就是依赖自身的状态来更新，不依赖外部变量

// 子组件
export const Button = (props) => {
    const [count] = useState(() => props.data * 3)
    return <button>props.data: {props.data} count:{count}</button>
}
// 父组件
const App = () => {
  const [data, setData] = useState(1)
    return(
      <div>
        <button onClick={() => setData(data + 1)}>data:{data}</button>
        <Button data={data} />
      </div>
    )
}
```
## useRef
> 存放数据，无论在哪里都能取到最新的状态，就需要使用useRef
```js
const [count, setCount] = useState(0)

useEffect(() => {
    const id = setInterval(() => {
        console.log(count) // 一直打印 0
        setCount(count + 1)
    }, 1000)
    return () => clearInterval(id)
}, [])
// 改成useRef
const [count, setCount] = useState(0)

const countRef = useRef(count)
countRef.current = count

useEffect(() => {
    const id = setInterval(() => {
        console.log(countRef.current)
        setCount( countRef.current = countRef.current + 1) // 0 1 2 3...
    })
    return () => clearInterval(id)
}, [])
```
> 这边注意，修改useRef的值并不会引起react的重新渲染
useRef的值改变并不会造成页面重新渲染，这一点可以做很多事情。比如可以配合useEffect查询页面是首次渲染还是更新。

使用`useRef`获取dom
```js
const App = () => {
    const domRef = useRef(null)

    useEffect(() => {
      console.log(domRef)
    })

    return(
      <div>
        <div ref={domRef} type="text"></div>
      </div>
    )
}
```

## useEffect
> 每次渲染生效之后执行
函数组件中，当组件完成挂载，这时候可以请求数据，可以使用useEffect
可以当成是class组件中的`componentDidMount`, `componentDidUpdate`, `componentWillUnmount `
的组合

`useEffect`第二个参数，当数组内的依赖发生变化时，则重新执行`useEffect`
```js
const [count, setCount] = useState(0)

useEffect(() => {
    console.log(count)
    // 当这里操作使用到了别的，eslint会提示你把它加入第二个参数，但是你实际上并不需要依赖它
    // 可以加上注释去忽视eslint的提示
    // eslint-disable-next-line react-hooks/exhaustive-deps
}, [])

// useEffect第二个参数，当数组内的依赖发生变化时，则重新执行useEffect
const [count, setCount] = useState(0)

useEffect(() => {
    console.log(count)
}, [count])

<button onClick={() => setCount(count + 1)}>+{count}</button>

// 如果需要在组件销毁的阶段，做一些操作，需要在useEffect结尾返回一个函数
// 相当于 componentWillUnmount
useEffect(() => {
    console.log(count)

    retrun () => clearInterval(timer)
}, [count])
```
- async
```js
useEffect(async () => {
    const res = await get()
}, [])
// 在外面包装一层
const getSomething = (callback) => {
    useEffect(() => {
        callback()
    }, [])
}
```

## useLayoutEffect
和`useEffect`传参一样，不过有以下区别
> 执行的时机不同，useLayoutEffect会在react更新DOM树后同步调用
> 在development模式下SSR会有警告
> 一般情况下回用在做动效和记录layout的一些特殊场景，一般不会使用

## useContext
来获取父组件传递的context值，父组件设置Provider设置的value值
两种方式来获取context的值
```js
const Context = React.createContext()

const App = () => {
    return(
      <div>
          <Context.Provider value={123}>
            <Countext1 />
            <Countext2 />
          </Context.Provider>
      </div>
    )
}

const Countext1 = () => {
  const value = useContext(Context)
  return <div>Countext1: { value }</div>
}

const Countext2 = () => {
  return <Context.Consumer>
      {(value) => <div>Countext2: { value }</div>}
  </Context.Consumer>
}
```

## useReducer
类似redux的api。
```js
// 简单使用
const App = () => {
    const[count, despatchCount] = useReducer((state, action) => {
      const { payload, type } = action
      
      switch(type){
        case 'add':
            return state + 1
        case 'sub':
            return state - 1 
        case 'reset':
          return payload       
      }
      return state
    }, 0)

    return(
      <div>
          { count }
          <button onClick={() =>despatchCount({ type: 'add'})}>add</button>
          <button onClick={() =>despatchCount({ type: 'sub'})}>sub</button>
          <button onClick={() =>despatchCount({ type: 'reset', payload: 123})}>reset</button>
          {/* 传给子组件 */}
          <Children dispatch={despatchCount} State={{ count }} />
      </div>
    )
}
```
## useMemo
它会保留上一次的计算，看结果是否变更，是否来使用上次的计算

```js
// 这里点击增加count 子组件也会重新render
// 虽然子组件并不依赖于父组件的count
const Child = ({data}) => {
  console.log('child render', data)
  return <div>{data}</div>
}

const App = () => {
    console.log('father render')
    const [count, setCount] = useState(0)
    const [data, setData] = useState('seagull')

    const name = useMemo(() => {
        return {
            data
        }
    }, [data])

    return <div>
      {count} 

      <button onClick={() => setCount(count + 1)}>count+</button>
      <Child data={name} />
    </div>
}
// 改成这样
const Child = memo(({data}) => {
  console.log('child render', data)
  return <div>child: {data}</div>
})

const App = () => {
    console.log('father render')
    const [count, setCount] = useState(0)
    const [data] = useState('seagull')

    const name = useMemo(() => {
      return data
    }, [data])

    return <div>
      {count} 

      <button onClick={() => setCount(count + 1)}>count+</button>
      <Child data={name} />
    </div>
}
```
## useCallback
简化版的`useMemo`

其实也没有必要为了性能优化去使用useMemo、useCallback、Profiling、React.mome去优化性能。
基本上大多数情况下现有的算法能满足性能的需求了

```js
const callback = useCallback((...args) => {
    // do something
}, [...deps])

const memo = useMemo((...args) => {
    // do something
}, [...deps])
```