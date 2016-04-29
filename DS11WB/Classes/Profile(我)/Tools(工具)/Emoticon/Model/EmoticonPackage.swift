//
//  EmoticonPackage.swift
//
//  Created by Cheney on 16/4/12.
//  Copyright © 2016年 Cheney. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject {
    var emoticons : [Emoticon] = [Emoticon]()
    
    init(id : String) {
        
        super.init()
        
        // 最近分组
        if id == "" {
            addEmptyEmoticon(true)
            return
        }
        
        // 根据id拼接info.plist的路径
        let plistPath = NSBundle.mainBundle().pathForResource("\(id)/info.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        
        // 根据plist文件的路径读取数据 [[String : String]]
        let array = NSArray(contentsOfFile: plistPath)! as! [[String : String]]
        
        // 遍历数组
        var index = 0
        for var dict in array {
            if let png = dict["png"] {
                dict["png"] = id + "/" + png
            }
            
            emoticons.append(Emoticon(dict: dict))
            index++
            
            if index == 20 {
                // 添加删除表情
                emoticons.append(Emoticon(isRemove: true))
                index = 0
            }
        }
        
        // 添加空白表情
        addEmptyEmoticon(false)
    }
    
    private func addEmptyEmoticon(isRecently : Bool) {
        let count = emoticons.count % 21
        if count == 0 && !isRecently {
            return
        }
        
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        
        emoticons.append(Emoticon(isRemove: true))
    }
}