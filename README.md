# JavaScriptInterface
UIWebview extension help you to call native code from Javascript in the iOS application.
Written by Swift 2.0. It's similar WebView.addJavascriptInterface in the Android application.

## Setting your project

Step 1: 
Expand the Link Binary With Libraries section and add the following item:
JavaScriptCore.framework

Step 2:
- Define a protocol, inherit from JSExport protocol, which contains these native functions as you want to work with JavaScript.
For example:

```swift
@objc protocol MyExport : JSExport
{
    func check(message : String)
    func sayGreeting(message: String, _ name: String)
    func anotherSayGreeting(message: String, name: String)
    func showDialog(title: String, _ message : String)
}
```

Step 3:
Define a class to implement native functions above.
```swift
class JSInterface : NSObject, MyExport
{
    func check(message: String) {
        print("JS Interface works!")
    }
    
    func sayGreeting(message: String, _ name: String)
    {
        print("sayGreeting: \(message): \(name)")
    }
    
    func anotherSayGreeting(message: String, name: String)
    {
        print("anotherSayGreeting: \(message): \(name)")
    }

    func showDialog(title: String, _ message : String)
    {
        dispatch_async(dispatch_get_main_queue(), {
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
}
```

Step 4:
Create an outlet to the webview in your view controller
```swift
@IBOutlet weak var webView : UIWebView!
```

Step 5: 
Add java script interface as below at viewDidLoad:
```swift
self.webView.addJavascriptInterface(JSInterface(), forKey: "Native");
```
##Usage
Now to call those native functions above from JavaScipt is loaded your webview, just call:

```swift
Native.check()

Native.sayGreeting('Hello', 'JavaScript Interface')

```




