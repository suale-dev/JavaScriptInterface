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
    func addJavascriptInterface<T : JSExport>(_ object: T, forKey key: String){
        if let existed = __jsExportDatas.first(where: { (exportData) -> Bool in
            return exportData.webView === self && exportData.key == key
        })
        {
            existed.export = object
        }
        else {
            let exportData = JSExportData(webView: self, export: object, key: key)
            __jsExportDatas.append(exportData)
        }
    }
    
    func removeJavascriptInterfaces(){
        
        let exportDatas = __jsExportDatas.filter({ (exportData) -> Bool in
            exportData.webView === self
        })
        
        for exportData in exportDatas {
            let context = exportData.context
            context?.setObject(nil, forKeyedSubscript: exportData.key as (NSCopying & NSObjectProtocol)!)
        }
        
        __jsExportDatas = __jsExportDatas.filter({ (exportData) -> Bool in
            exportData.webView !== self
        })
        print("count: \(__jsExportDatas.count)")
        
    }
    
    func callJSMethod(name: String, agruments: String...) -> String?{
        var agrumentString = ""
        for agrument in agruments {
            if agrumentString.count > 0 {
                agrumentString = "\(agrumentString),"
            }
            agrumentString = "\(agrumentString)'\(agrument)'"
        }
        
        return self.stringByEvaluatingJavaScript(from: "\(name)(\(agrumentString))")
    }
}


extension NSObject
{
    @objc func webView(_ webView: AnyObject!, didCreateJavaScriptContext context: JSContext!, forFrame frame: AnyObject!)
    {
        let notifyDidCreateJavaScriptContext = {() -> Void in
            for exportData in __jsExportDatas
            {
                if exportData.export == nil{
                    continue
                }                                
                let webView = exportData.webView!
                let checksum = "__KKKWebView\(webView.hash)"
                webView.stringByEvaluatingJavaScript(from: "var \(checksum) = '\(checksum)'")
                if context.objectForKeyedSubscript(checksum).toString() == checksum
                {
                    context.setObject(exportData.export!, forKeyedSubscript: exportData.key as (NSCopying & NSObjectProtocol)!)
                    exportData.context = context
                }
            }
        }
        
        if (Thread.isMainThread)
        {
            notifyDidCreateJavaScriptContext()
        }
        else
        {
            DispatchQueue.main.async(execute: notifyDidCreateJavaScriptContext)
        }
    }
}

class JSExportData{
    weak var webView: UIWebView?
    var export : JSExport?
    var key: String = "Native"
    var context: JSContext?
    
    init(webView: UIWebView, export: JSExport, key: String = "Native") {
        self.webView = webView
        self.export = export
        self.key = key
    }
}
var __jsExportDatas : [JSExportData] = []
