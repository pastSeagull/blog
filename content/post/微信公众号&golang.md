---
title: "微信公众号&golang"
date: 2022-05-04T11:52:35+08:00
---

本篇是关于如何拿到`wx.config`所需要的参数。
<!--more-->

## 测试号
首先你要先去申请一个，拿到测试号的`appID` `appsecret`
https://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=sandbox/login

我们先看一下微信`jssdk`的`config`需要什么
```js
wx.config({
    debug: true, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
    appId: '', // 必填，公众号的唯一标识
    timestamp: , // 必填，生成签名的时间戳
    nonceStr: '', // 必填，生成签名的随机串
    signature: '',// 必填，签名
    jsApiList: [] // 必填，需要使用的JS接口列表
});
```
### signature

1、通过测试号的`appId`和`appsecret`我们先获取`access_token`，通过下面接口获取。
> https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=${appid}&secret=${secret}

2、拿到`access_token`后在使用`access_token`去获取`jsapi_ticket`，有效期只有7200秒，我们需要缓存`jsapi_ticket`。
> https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=ACCESS_TOKEN&type=jsapi

我们拿到`jsapi_ticket`后就可以生成`jssdk`的签名了。

看一下代码

拿到`access_token`和`jsapi_ticket`
```golang
func GetWeixin(appid, secret string) {
	var tk Token
	var tc Ticket
	db, err := storm.Open("db/weixin.db")
	if err != nil {
		log.Println("Database open err:", err.Error())
	}
	defer db.Close()

	gorequest.New().Get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" + appid + "&secret=" + secret).EndStruct(&tk)
	gorequest.New().Get("https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=" + tk.AccessToken + "&type=jsapi").EndStruct(&tc)

	if e := db.Set("sessions", "token", &tk); e != nil {
		log.Println(e.Error())
	}
	if e := db.Set("sessions", "ticket", &tc); e != nil {
		log.Println(e.Error())
	}
}
```
#### 签名算法
> 签名生成规则如下：参与签名的字段包括noncestr（随机字符串）, 有效的jsapi_ticket, timestamp（时间戳）, 
> url（当前网页的URL，不包含#及其后面部分） 。对所有待签名参数按照字段名的ASCII 码从小到大排序（字典序）后，
> 使用URL键值对的格式（即key1=value1&key2=value2…）拼接成字符串string1。这里需要注意的是所有参数名均为小写字符。
> 对string1作sha1加密，字段名和字段值都采用原始值，不进行URL 转义。

具体看官方文档
https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#62

生成随机字符串
```go
letterRunes := []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func RandStringRunes(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letterRunes[rand.Intn(len(letterRunes))]
	}
	return string(b)
}
```
微信签名算法并缓存
```go
func GetCanshu(noncestr, url string) (timestamp, signature string) {
	db, err := storm.Open("db/weixin.db")
	if err != nil {
		log.Println("Database open err:", err.Error())
	}
	defer db.Close()

	defer func() { //异常处理
		if err := recover(); err != nil {
			time.Sleep(time.Duration(3) * time.Second)
		}
	}()
	var tc Ticket
	if e := db.Get("sessions", "ticket", &tc); e != nil {
		panic(e.Error())
	}

	timestamp = strconv.FormatInt(time.Now().Unix(), 10)
	longstr := "jsapi_ticket=" + tc.Ticket + "&noncestr=" + noncestr + "&timestamp=" + timestamp + "&url=" + url

	h := sha1.New()
	if _, e := h.Write([]byte(longstr)); e != nil {
		log.Println(e.Error())
	}

	signature = fmt.Sprintf("%x", h.Sum(nil))
	return
}
```
生成签名
```go
func signHandler(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	w.Header().Set("Access-Control-Allow-Origin", "*") //允许访问所有域

	wxNoncestr := RandStringRunes(32)
	wxURL, _ := url.QueryUnescape(r.FormValue("url"))
	timestamp, signature := GetCanshu(wxNoncestr, wxURL)
	var u = Sign{
		AppID:     wxAppID,
		Timestamp: timestamp,
		NonceStr:  wxNoncestr,
		Signature: signature,
	}
	fmt.Println("get sign", u)
	w.Header().Add("Access-Control-Allow-Headers", "Content-Type") //header的类型
	w.Header().Set("Content-type", "application/json")             //返回数据格式是json
	b, err := json.Marshal(u)
	if err != nil {
		log.Println(err.Error())
	}
	w.Write(b)
}
```
最后接口给前端即可。
> http.HandleFunc("/sign", signHandler)

完整代码
> https://github.com/pastSeagull/Learn-demo/tree/main/wx

## 前端
通过接口获取`wx.config`需要的参数。
```js
export const App = () => {
  const scanQRCode = () => {
    sign().then(res => {

      wx.config({
        debug: true,
        appId: res.app_id,
        timestamp: res.timestamp,
        nonceStr: res.nonce_str,
        signature: res.signature,
        jsApiList: [
          'scanQRCode'
        ]
      })
      // 成功or失败回调
      wx.ready(() => {
        console.log("ok")

        wx.scanQRCode({
          needResult: 0, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
          scanType: ["qrCode","barCode"], // 可以指定扫二维码还是一维码，默认二者都有
          success: function (res: any) {
            let result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
          }
        });

      })
      wx.error((err: Error) => {
        console.log("err", err)
      })
    })
  }

  return <div>
    <button onClick={scanQRCode}>扫一扫</button>
  </div>
}
```



## 参考
___
1. [微信测试号接入微信sdk本地开发调试](https://juejin.cn/post/6989882775994269726)
2. https://github.com/henson/wxtoken
