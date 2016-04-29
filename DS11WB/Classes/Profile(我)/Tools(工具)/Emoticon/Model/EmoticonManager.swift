//
//  EmoticonManager.swift
//
//  Created by Cheney on 16/4/12.
//  Copyright © 2016年 Cheney. All rights reserved.
//

import UIKit

class EmoticonManager {
    var packages : [EmoticonPackage] = [EmoticonPackage]()
    
    init () {
        // 添加最近表情的包
        packages.append(EmoticonPackage(id: ""))
        
        // 添加默认表情的包
        packages.append(EmoticonPackage(id: "com.sina.default"))
        
        // 添加emoji表情的包
        packages.append(EmoticonPackage(id: "com.apple.emoji"))
        
        // 添加浪小花表情的包
        packages.append(EmoticonPackage(id: "com.sina.lxh"))
    }
}