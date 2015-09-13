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


class KWebView: UIWebView {
    
    var exportObject : AnyObject? = nil
    var keyBinding : String = "Native" //placeholder
    var currentContext : JSContext?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        __globalWebViews.append(self)
    }
    
    func getCurrentContext() -> JSContext?
    {
        return currentContext
    }
    
    func addJavascriptInterface<T : JSExport>(object: T, forKey key: String)
    {
        exportObject = object
        keyBinding = key
    }
    
    func bindContext(context: JSContext!)
    {
        context.setObject(exportObject, forKeyedSubscript: keyBinding)
        currentContext = context
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
                    if let webView = webView as? KWebView
                    {
                        webView.bindContext(context)
                    }
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

