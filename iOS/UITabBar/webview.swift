//
//  webview.swift
//  UITabBar
//
//  Created by Navrit Bal on 26/07/15.
//  Copyright (c) 2015 navrit. All rights reserved.
//

import UIKit

class webview: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: "http://radwatch.berkeley.edu/")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }
    
    func action(gestureRecognizer:UIGestureRecognizer){

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

