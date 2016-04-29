//
//  UIBarButtonItem-Extension.swift
//  DS11WB
//
//  Created by Cheney on 16/4/5.
//  Copyright © 2016年 Cheney. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    /*
    convenience init(imageName : String) {
        self.init()
        
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: .Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: .Highlighted)
        btn.sizeToFit()
        
        self.customView = btn
    }
    */
    
    convenience init(imageName : String) {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: .Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: .Highlighted)
        btn.sizeToFit()
        
        self.init(customView : btn)
    }
}