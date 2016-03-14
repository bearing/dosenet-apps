//
//  InfoViewController.swift
//  DoseNet
//
//  Created by Navrit Bal on 30/12/2015.
//  Copyright © 2015 navrit. All rights reserved.
//

import UIKit
import SwiftSpinner

class InfoViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!

    func main() {
        SwiftSpinner.show("Loading...")
        webRequest()
    }
    
    func webRequest() {
        let url = NSURL (string: "https://radwatch.berkeley.edu/dosenet/about")
        let requestObj = NSURLRequest(URL: url!)
        
        self.webView.loadRequest(requestObj)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        SwiftSpinner.show("Loading webpage...").addTapHandler({
            SwiftSpinner.hide()
        }, subtitle: "Tap to hide while connecting! This will affect only the current operation.")

    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SwiftSpinner.hide()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        main()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

