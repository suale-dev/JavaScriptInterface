//
//  JSInterface.swift
//  JSInterface
//
//  Created by Kem on 9/12/15.
//  Copyright © 2015 Kem. All rights reserved.
//

import Foundation
import JavaScriptCore
import UIKit

@objc protocol MyExport : JSExport
{
    func check(_ message : String)
    func sayGreeting(_ message: String, _ name: String)
    func anotherSayGreeting(_ message: String, name: String)
    func showDialog(_ title: String, _ message : String)
}


class JSInterface : NSObject, MyExport
{
    func check(_ message: String) {
        print("JS Interface works!")
    }
    
    func sayGreeting(_ message: String, _ name: String)
    {
        print("sayGreeting: \(message): \(name)")
    }
    
    func anotherSayGreeting(_ message: String, name: String)
    {
        print("anotherSayGreeting: \(message): \(name)")
    }

    func showDialog(_ title: String, _ message : String)
    {
        DispatchQueue.main.async(execute: {
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
}
