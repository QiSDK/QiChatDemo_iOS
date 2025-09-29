## 把ChatLib作为一个全局的消息监听器，不管用户进入了哪个页面，都能收到消息。

## 在Constant.swift里面多一个动态unReadList，每个item有2个字段，consultId和它的未读数, 只要用户不在聊天页面收到的消息，每收到1条消息这个consultId对应的未读数就+1。

## 在首页/Users/xuefeng/Desktop/teneasy/QiChatDemo_iOS/Example/TeneasyChatSDKUI_iOS/ViewController.swift，多加一个未读数label. 用来显示未读的消息总数。

## 在ConsultTypeViewController.swift客服咨询列表页面，已经有未读数的显示，但是如果当用户停留在这页面的时候，有消息收到，就更新列表里面的未读数。

ChatLib的使用，可以参考已有的代码：TeneasyChatSDKUI_iOS/Classes/Controller/KeFuViewController_ChatSDK.swift