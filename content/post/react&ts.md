---
title: "React&ts"
date: 2022-08-05T13:25:08+08:00
draft: false
---

React的一些Ts类型
<!--more-->

## Basic
- 指定精确的值
```ts
type TStatus = status: "waiting" | "success";
```
- arrayList
```ts
type objArr = {
  id: string;
  title: string;
}[];
// use
const [objArr] = useState<objArr>(
    [
        {
            id: 1,
            title: "title"
        }
    ]
)
// or
interface objArr {
    id: string;
    title: string;
}
const [objArr] = useState<objArr[]>([])
```

- key是同一个类型，但是值可以多个类型
```ts
type dict = {
    [key: string]: number | string;
}
// 或者这样
type dict2 = Record<string, number | string>

// use
const [dict] = useState<dict>(
    {
        "key": 1,
        "key1": "2",
    }
)
```

- event
```ts
const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {}
<input type="text" onChange={onChange}/>

const onClick = (event: React.MouseEvent<HTMLButtonElement>) => {}
<button onClick={onClick}>1</button>
```

- 组件作为参数
```ts
export const Basic = ({ children }: { children: ReactNode }) => {
    return <div>
        {children}
    </div>
}

<Basic>
    <Title />
</Basic>
```

- 函数组件
一般来说函数组件是这样写的
> `FC`是`FunctionComponent`的缩写，里面定义默认的`props`
```ts
export const Basic: React.FC<{ children: ReactNode }> = ({ children } ) => {
    return <div>
        {children}
    </div>
}
```
但是React18移除FC的隐式的children，我看很多篇博客都说不要推荐使用了

使用VFC
> `type React.VFC<P = {}> = React.VoidFunctionComponent<P>`
> 
>  @deprecated — - Equivalent with React.FC.

```js
type FC<P = {}> = FunctionComponent<P>;

interface FunctionComponent<P = {}> {
    (props: P, context?: any): ReactElement<any, any> | null;
    propTypes?: WeakValidationMap<P> | undefined;
    contextTypes?: ValidationMap<any> | undefined;
    defaultProps?: Partial<P> | undefined;
    displayName?: string | undefined;
}

/**
 * @deprecated - Equivalent with `React.FC`.
 */
type VFC<P = {}> = VoidFunctionComponent<P>;

/**
 * @deprecated - Equivalent with `React.FunctionComponent`.
 */
interface VoidFunctionComponent<P = {}> {
    (props: P, context?: any): ReactElement<any, any> | null;
    propTypes?: WeakValidationMap<P> | undefined;
    contextTypes?: ValidationMap<any> | undefined;
    defaultProps?: Partial<P> | undefined;
    displayName?: string | undefined;
}
```
https://www.mydatahack.com/using-react-vfc-instead-of-react-fc/

https://fettblog.eu/typescript-react-why-i-dont-use-react-fc/

## hooks
- as
```ts
type TUser = {
    name: string,
    age: number
}
// Argument of type '{}' is not assignable to parameter of type 'TUser | (() => TUser)'.
const [user, setUser] = useState<TUser>({})
// as
const [user, setUser] = useState<TUser>({} as TUser)
```
### useReducer
reducer的类型
```ts
const initialState = { count: 0 };

type ACTIONTYPE =
  | { type: "increment"; payload: number }
  | { type: "decrement"; payload: string };

function reducer(state: typeof initialState, action: ACTIONTYPE) {
  switch (action.type) {
    case "increment":
      return { count: state.count + action.payload };
    case "decrement":
      return { count: state.count - Number(action.payload) };
    default:
      throw new Error();
  }
}

function Counter() {
  const [state, dispatch] = React.useReducer(reducer, initialState);
  return (
    <>
      Count: {state.count}
      <button onClick={() => dispatch({ type: "decrement", payload: "5" })}>
        -
      </button>
      <button onClick={() => dispatch({ type: "increment", payload: 5 })}>
        +
      </button>
    </>
  );
}
```

### ref
- 使用ref来获取dom节点
```ts
// 获取div
const divRef = useRef<HTMLDivElement>(null);

// 这里要注意获取input的时候要用HTMLInputElement
```

## Custom Hooks
自定义hooks
这里如果你要自定义一个hooks，返回的的是一个数组的时候应该使用断言`as const`
```ts
export function useLoading() {
  const [isLoading, setState] = useState(false);
  const load = (aPromise: Promise<any>) => {
    setState(true);
    return aPromise.finally(() => setState(false));
  };
  return [isLoading, load] as const;
}
// 不使用 as const 的类型
// const isLoading: boolean | ((aPromise: Promise<any>) => Promise<any>)
// const load: boolean | ((aPromise: Promise<any>) => Promise<any>)

// 使用后的类型
// const isLoading: boolean
// const load: (aPromise: Promise<any>) => Promise<any>
```
当然你也可以自定义`return`的类型
```ts
return [isLoading, load] as [
  boolean,
  (aPromise: Promise<any>) => Promise<any>
];
```

## Class Components
一个简单的class组件
```ts
type TProps = {
    message: string
}
type TState = {
    name: string
    age: number
}

export class App extends Component<TProps, TState> {
    state: TState = {
        name: 'name',
        age: 17
    }

    changeAge = (amount: number) => {
      this.setState(state => ({
        age: state.age + amount
      }))
    }

    render() {
        return(
            <div>
              {this.props.message} {this.state.age}
              <button onClick={() => this.changeAge(1)}>+</button>
            </div>
        )
    }
}

// 当然你也可以这样
export class App extends Component<{
  message: string
}> {
  age: number
  changeAge() {
    this.age = 18
  }
  render() {
    return(
      <div>
        {this.props.message} {this.age}
      </div>
    )
  }
}
```

## 参考
___
1. [react-typescript-cheatsheet](https://react-typescript-cheatsheet.netlify.app/)

