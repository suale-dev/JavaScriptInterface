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
    func check(message : String)
    func sayGreeting(message: String, _ name: String)
    func anotherSayGreeting(message: String, name: String)
    func showDialog(title: String, _ message : String)
}


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