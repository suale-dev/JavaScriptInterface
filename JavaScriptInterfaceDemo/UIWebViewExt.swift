//
//  KWebView.swift
//  JSInterface
//
//  Created by Kem on 9/12/15.
//  Copyright © 2015 Kem. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore


extension UIWebView {
    func addJavascriptInterface<T : JSExport>(object: T, forKey key: String){
        __globalWebViews.append(self)
        __globalKeyBinding = key
        __globalExportObject = object
    }
}


extension NSObject
{
    func webView(webView: UIWebView!, didCreateJavaScriptContext context: JSContext!, forFrame frame: AnyObject!)
    {
        let notifyDidCreateJavaScriptContext = {() -> Void in
            for webView in __globalWebViews
            {
                let checksum = "__KKKWebView\(webView.hash)"
                webView.stringByEvaluatingJavaScriptFromString("var \(checksum) = '\(checksum)'")
                if context.objectForKeyedSubscript(checksum).toString() == checksum
                {
                    context.setObject(__globalExportObject, forKeyedSubscript: __globalKeyBinding)                    
                }
            }
        }
        
        if (NSThread.isMainThread())
        {
            notifyDidCreateJavaScriptContext()
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), notifyDidCreateJavaScriptContext)
        }
    }
}

var __globalWebViews : [UIWebView] = []
var __globalExportObject : AnyObject? = nil
var __globalKeyBinding : String = "Native" //placeholder
