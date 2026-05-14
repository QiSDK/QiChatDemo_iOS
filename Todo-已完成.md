在进入聊天页面的时候，需要调用下面的接口，如果evaluationEnabled = true，就需要在底部左下角显示一个客服评价的按钮，点击后会出现评价弹窗，评价之后，如果里面的status = 1,就需要出现一个Toast("感谢反馈!")，如果 = 2， 就不需要。

[http] 16:36:42 --> POST /v1/tenant/evaluation/config/info HTTP/1.1
Content-Type: application/json
x-token: COgBEAMYASAPKKTO8MuQMw.0Z52SGtj544k8P7s1EfEKt9EuGn0VaXdcBiKGKaAOhC98uXHiut1QOjIoajjHbcww4H8YlMou-nA87WPcKALAg

{}

[http] 16:36:42 <-- HTTP/1.1 200 OK (5ms)
Content-Length: 592
Content-Type: application/json
X-Trace-Id: 8cc21cac-deeb-495a-8a82-db9717ee9ced
Date: Tue, 14 Oct 2025 13:36:42 GMT

{
  "code": 0,
  "msg": "OK",
  "data": {
    "evaluationEnabled": false,
    "configs": [
      {
        "content": "非常不满意",
        "score": 1,
        "feedback": "感谢反馈",
        "status": 1
      },
      {
        "content": "不满意",
        "score": 2,
        "feedback": "",
        "status": 2
      },
      {
        "content": "一般",
        "score": 3,
        "feedback": "",
        "status": 2
      },
      {
        "content": "满意",
        "score": 4,
        "feedback": "",
        "status": 2
      },
      {
        "content": "非常满意",
        "score": 5,
        "feedback": "",
        "status": 2
      }
    ],
    "triggerMessages": [
      "请为本次服务打分",
      "服务结束啦，欢迎评价",
      "感谢反馈，欢迎评价"
    ]
  }
}

## 添加评价接口：
[http] 15:23:36 --> POST /v1/tenant/evaluation/add 

{
  "consultId": 112,
  "score": 5,
  "remark": "测试评价脚本",
  "close": 0
}

[http] 15:23:36 <-- HTTP/1.1 200 OK (8ms)
X-Trace-Id: f77e9e19-3326-45b2-85c0-e7515baa7d05
Date: Wed, 15 Oct 2025 12:23:36 GMT
Content-Type: application/json

{
  "code": 1001,
  "msg": "会话已评价，不能重复评价",
  "line": 139,
  "file": "evaluation_service"
}


## 获取评价状态
[http] 15:20:09 --> POST /v1/tenant/evaluation/status/get 

{
  "consultId": 112
}

[http] 15:20:09 <-- HTTP/1.1 200 OK (13ms)
X-Trace-Id: 634305d2-e936-44fe-bba0-598d0e50ef9b
Date: Wed, 15 Oct 2025 12:20:09 GMT
Content-Type: application/json

{
  "code": 0,
  "msg": "OK",
  "data": {
    "status": 2
  }
}