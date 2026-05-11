# TeneasyChatSDKUI_iOS

A UI-layer chat SDK that lets your iOS app present a customer-service chat page with a configurable theme.

## Installation

```ruby
pod 'TeneasyChatSDKUI_iOS', '~> 1.1.0'
```

## Recommended Integration

The recommended entry point is `KeFuViewController`. Your app supplies the `consultId` (from your own backend or consult-selection UI) and an optional `ChatTheme`:

```swift
import TeneasyChatSDKUI_iOS

let theme = ChatTheme(
    gradientStartColor: UIColor.white,
    gradientEndColor:   UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.8),
    gradientDirection: .topToBottom,
    tintColor: .systemBlue
)

let chatVC = KeFuViewController(consultId: 123, theme: theme)
chatVC.modalPresentationStyle = .fullScreen
present(chatVC, animated: true)
```

If you omit the theme, the SDK falls back to `ChatTheme.default` (a soft blue gradient).

## ChatTheme

```swift
public struct ChatTheme {
    public var gradientStartColor: UIColor   // supports alpha
    public var gradientEndColor: UIColor     // supports alpha
    public var gradientDirection: GradientDirection
    public var tintColor: UIColor            // back button, send button, attachment icons

    public enum GradientDirection {
        case topToBottom, bottomToTop
        case leftToRight, rightToLeft
        case topLeftToBottomRight, topRightToBottomLeft
    }

    public static let `default`: ChatTheme   // 内置浅蓝渐变
}
```

The gradient fills the entire chat page background. `tintColor` is applied to the navigation back icon and toolbar icons; message bubbles keep their original colors for readability.

## Unread Count Access

The SDK maintains per-consult and total unread counters via `GlobalMessageManager`. Your host app can read them at any time:

```swift
// Total unread count across all consults
let total = GlobalMessageManager.shared.getTotalUnReadCount()

// Per-consult unread count
let count = GlobalMessageManager.shared.getUnReadCount(consultId: 123)
```

To get notified of changes (e.g., to update a badge), conform to `GlobalMessageDelegate`:

```swift
class HomeViewController: UIViewController, GlobalMessageDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        globalMessageDelegate = self
    }

    func onUnReadCountChanged() {
        DispatchQueue.main.async {
            self.badgeLabel.text = "\(GlobalMessageManager.shared.getTotalUnReadCount())"
        }
    }
}
```

`globalMessageDelegate` is a single-slot global delegate — the most recently assigned object receives the callback.

## Global Chat Connection

Initialize the global chat connection once your app has resolved the gateway domain (typically after a `LineDetectLib` check):

```swift
domain = "<resolved gateway domain>"
GlobalChatManager.shared.initializeGlobalChat()
GlobalChatManager.shared.connectIfNeeded()
```

The manager auto-reconnects every 6 seconds and routes incoming messages to `GlobalMessageManager` for unread tracking, even when the chat page is not on screen.

## Legacy

`ConsultTypeViewController` is included for the demo project's convenience and is **not the recommended integration path**. New apps should obtain `consultId` through their own consult-selection UI or backend and launch `KeFuViewController` directly.

## Demo

See `Example/` for a working integration that combines line detection, consult selection, global unread counts, and theme customization.

## License

MIT — see `LICENSE`.
