//
//  InfoViewController.swift
//  DoseNet
//
//  Created by Navrit Bal on 30/12/2015.
//  Copyright © 2015 navrit. All rights reserved.
//

import UIKit
import Alamofire

class InfoViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL (string: "https://radwatch.berkeley.edu/dosenet");
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

