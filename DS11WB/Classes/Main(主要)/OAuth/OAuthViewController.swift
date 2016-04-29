//
//  OAuthViewController.swift
//  DS11WB
//
//  Created by Cheney on 16/4/6.
//  Copyright © 2016年 Cheney. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {
    // MARK:- 控件的属性
    @IBOutlet weak var webView: UIWebView!
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏的内容
        setupNavigationBar()
        
        // 加载网页
        loadPage()
    }
    
}


// MARK:- 设置UI界面相关
extension OAuthViewController {
    private func setupNavigationBar() {
        // 设置左侧的item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "closeItemClick")
        
        // 设置右侧的item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填充", style: .Plain, target: self, action: "fillItemClick")
        
        // 设置标题
        title = "登录页面"
    }
    
    private func loadPage() {
        // 获取登录页面的URLString
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(app_key)&redirect_uri=\(redirect_uri)"
        
        // 创建对应NSURL
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        // 创建NSURLRequest对象
        let request = NSURLRequest(URL: url)
        
        // 加载request对象
        webView.loadRequest(request)
    }
}

// MARK:- 事件监听函数
extension OAuthViewController {
    @objc private func closeItemClick() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func fillItemClick() {
        // 书写js代码
        let jsCode = "document.getElementById('userId').value='383163460@qq.com';document.getElementById('passwd').value='Wang13648067515';"
        
        // 执行js代码
        webView.stringByEvaluatingJavaScriptFromString(jsCode)
    }
}


// MARK:- webView的delegate方法
extension OAuthViewController : UIWebViewDelegate {
    // webView开始加载网页
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    // webView网页加载完成
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    // webView加载网页失败
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        SVProgressHUD.dismiss()
    }
    
    
    // 当准备加载某一个页面时,会执行该方法
    // 返回值: true -> 继续加载该页面 false -> 不会加载该页面
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 获取加载网页的NSURL
        guard let url = request.URL else {
            return true
        }
        
        // 获取url中的字符串
        let urlString = url.absoluteString
        
        
        // 判断该字符串中是否包含code
        guard urlString.containsString("code=") else {
            return true
        }
        
        // 将code截取出来
        let code = urlString.componentsSeparatedByString("code=").last!
        
        // 请求accessToken
        loadAccessToken(code)
        
        return false
    }
}


// MARK:- 请求数据
extension OAuthViewController {
    /// 请求AccessToken
    private func loadAccessToken(code : String) {
        NetworkTools.shareInstance.loadAccessToken(code) { (result, error) -> () in
            // 错误校验
            if error != nil {
                print(error)
                return
            }
            
            // 拿到结果
            guard let accountDict = result else {
                print("没有获取授权后的数据")
                return
            }
            
            // 将字典转成模型对象
            let account = UserAccount(dict: accountDict)
            
            // 请求用户信息
            self.loadUserInfo(account)
        }
    }
    
    
    /// 请求用户信息
    private func loadUserInfo(account : UserAccount) {
        // 获取AccessToken
        guard let accessToken = account.access_token else {
            return
        }
        
        // 获取uid
        guard let uid = account.uid else {
            return
        }
        
        // 发送网络请求
        NetworkTools.shareInstance.loadUserInfo(accessToken, uid: uid) { (result, error) -> () in
            // 错误校验
            if error != nil {
                print(error)
                return
            }
            
            // 拿到用户信息的结果
            guard let userInfoDict = result else {
                return
            }
            
            // 从字典中取出昵称和用户头像地址
            account.screen_name = userInfoDict["screen_name"] as? String
            account.avatar_large = userInfoDict["avatar_large"] as? String
            
            // 将account对象保存
            NSKeyedArchiver.archiveRootObject(account, toFile: UserAccountViewModel.shareIntance.accountPath)
            
            // 将account对象设置到单例对象中
            UserAccountViewModel.shareIntance.account = account
            
            // 退出当前控制器
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                UIApplication.sharedApplication().keyWindow?.rootViewController = WelcomeViewController()
            })
        }
    }
}