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
            context?.setObject(nil, forKeyedSubscript: exportData.key as (NSCopying & NSObjectProtocol)?)
        }
        
        __jsExportDatas = __jsExportDatas.filter({ (exportData) -> Bool in
            exportData.webView !== self
        })
        print("count: \(__jsExportDatas.count)")
        
    }
    
    @discardableResult
    func callJSMethod(name: String, agruments: StringConvertable...) -> String?{
        var agrumentString = ""
        for agrument in agruments {
            if agrumentString.count > 0 {
                agrumentString = "\(agrumentString),"
            }
            if agrument is String {
                agrumentString = "\(agrumentString)'\(agrument)'"
            } else if agrument is NSNumber {
                agrumentString = "\(agrumentString)\(agrument)"
            } else  if let agrument = agrument as? [String: Any] {
                if let json = try? JSONSerialization.data(withJSONObject: agrument, options: []), let jsonString = String(data: json, encoding: .utf8) {
                    agrumentString = "\(agrumentString)\(jsonString)"
                } else {
                    fatalError("Only support [String: String] or [String: Numberic] !!")
                }
            } else {
                fatalError("Only support string or number or dictionary !!")
            }
        }
        let js = "\(name)(\(agrumentString))"
        print("call: \(js)")
        return self.stringByEvaluatingJavaScript(from: js)
    }
}

protocol StringConvertable {}
extension Int: StringConvertable {}
extension Float: StringConvertable {}
extension Double: StringConvertable {}
extension CGFloat: StringConvertable {}
extension String: StringConvertable {}
extension Dictionary: StringConvertable {}
//TODO: update callJSMethod to support Array
//extension Array: StringConvertable {}

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
                    context.setObject(exportData.export!, forKeyedSubscript: exportData.key as (NSCopying & NSObjectProtocol)?)
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
