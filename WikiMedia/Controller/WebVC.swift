//
//  WebVC.swift
//  WikiMedia
//
//  Created by Anshu Vij on 1/23/21.
//

import UIKit
import WebKit

class WebVC: UIViewController,WKNavigationDelegate {

    var webView: WKWebView!
    var url:String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        
        navigationController?.navigationBar.isHidden = false
        if let url = url {
            let url = URL(string: url)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
        
    }

}
