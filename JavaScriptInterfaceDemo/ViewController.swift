//
//  ViewController.swift
//  JSInterface
//
//  Created by Kem on 9/11/15.
//  Copyright © 2015 Kem. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var webView : UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "/")
        if let indexPath = indexPath
        {
            do
            {
                let htmlContent = try String(contentsOfFile: indexPath, encoding: String.Encoding.utf8)
                
                let base = Bundle.main.resourceURL
                
                self.webView.addJavascriptInterface(JSInterface(), forKey: "Native");
                
                self.webView.loadHTMLString(htmlContent, baseURL: base)
                
            }
            catch let err as NSError
            {
                print(err.debugDescription)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

