//
//  HomeViewCell.swift
//  DS11WB
//
//  Created by Cheney on 16/4/8.
//  Copyright © 2016年 Cheney. All rights reserved.
//

import UIKit
import SDWebImage
import HYLabel

private let edgeMargin : CGFloat = 15
private let itemMargin : CGFloat = 10

class HomeViewCell: UITableViewCell {
    // MARK:- 控件属性
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var verifiedView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var vipView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var contentLabel: HYLabel!
    @IBOutlet weak var picView: PicCollectionView!
    @IBOutlet weak var retweetedContentLabel: HYLabel!
    @IBOutlet weak var retweetedBgView: UIView!
    @IBOutlet weak var bottomToolView: UIView!
    
    // MARK:- 约束的属性
    @IBOutlet weak var contentLabelWCons: NSLayoutConstraint!
    @IBOutlet weak var picViewHCons: NSLayoutConstraint!
    @IBOutlet weak var picViewWCons: NSLayoutConstraint!
    @IBOutlet weak var picViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var retweetedContentLabelTopCons: NSLayoutConstraint!
    
    // MARK:- 自定义属性
    var viewModel : StatusViewModel? {
        didSet {
            // nil值校验
            guard let viewModel = viewModel else {
                return
            }
            
            // 设置头像
            iconView.sd_setImageWithURL(viewModel.profileURL, placeholderImage: UIImage(named: "avatar_default_small"))
            
            // 设置认证的图标
            verifiedView.image = viewModel.verifiedImage
            
            // 昵称
            screenNameLabel.text = viewModel.status?.user?.screen_name
            
            // 会员图标
            vipView.image = viewModel.vipImage
            
            // 设置时间的Label
            timeLabel.text = viewModel.createAtText
            
            // 设置微博正文
            contentLabel.attributedText = FindEmoticon.shareIntance.findAttrString(viewModel.status?.text, font: contentLabel.font)
            
            // 设置来源
            if let sourceText = viewModel.sourceText {
                sourceLabel.text = "来自 " + sourceText
            } else {
                sourceLabel.text = nil
            }
            
            // 设置昵称的文字颜色
            screenNameLabel.textColor = viewModel.vipImage == nil ? UIColor.blackColor() : UIColor.orangeColor()
            
            // 计算picView的宽度和高度的约束
            let picViewSize = calculatePicViewSize(viewModel.picURLs.count)
            picViewWCons.constant = picViewSize.width
            picViewHCons.constant = picViewSize.height
            
            // 将picURL数据传递给picView
            picView.picURLs = viewModel.picURLs
            
            // 设置转发微博的正文
            if viewModel.status?.retweeted_status != nil {
                // 设置转发微博的正文
                if let screenName = viewModel.status?.retweeted_status?.user?.screen_name, retweetedText = viewModel.status?.retweeted_status?.text {
                    let retweetedText = "@" + "\(screenName): " + retweetedText
                    retweetedContentLabel.attributedText = FindEmoticon.shareIntance.findAttrString(retweetedText, font: retweetedContentLabel.font)
                    
                    // 设置转发正文距离顶部的约束
                    retweetedContentLabelTopCons.constant = 15
                }
                
                // 设置背景显示
                retweetedBgView.hidden = false
            } else {
                // 设置转发微博的正文
                retweetedContentLabel.text = nil
                
                // 设置背景显示
                retweetedBgView.hidden = true
                
                // 设置转发正文距离顶部的约束
                retweetedContentLabelTopCons.constant = 0
            }
            
            // 计算cell的高度
            if viewModel.cellHeight == 0 {
                // 强制布局
                layoutIfNeeded()
                
                // 获取底部工具栏的最大Y值
                viewModel.cellHeight = CGRectGetMaxY(bottomToolView.frame)
            }
        }
    }
    
    
    // MARK:- 系统回调函数
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设置微博正文的宽度约束
        contentLabelWCons.constant = UIScreen.mainScreen().bounds.width - 2 * edgeMargin
        
        // 设置HYLabel的内容
        contentLabel.matchTextColor = UIColor.purpleColor()
        retweetedContentLabel.matchTextColor = UIColor.purpleColor()
        
        // 监听HYlabel内容的点击
        // 监听@谁谁谁的点击
        contentLabel.userTapHandler = { (label, user, range) in
            print(user)
            print(range)
        }
        
        // 监听链接的点击
        contentLabel.linkTapHandler = { (label, link, range) in
            print(link)
            print(range)
        }
        
        // 监听话题的点击
        contentLabel.topicTapHandler = { (label, topic, range) in
            print(topic)
            print(range)
        }
    }
}

// MARK:- 计算方法
extension HomeViewCell {
    private func calculatePicViewSize(count : Int) -> CGSize {
        // 没有配图
        if count == 0 {
            picViewBottomCons.constant = 0
            return CGSizeZero
        }
        
        // 有配图需要改约束有值
        picViewBottomCons.constant = 10
        
        // 取出picView对应的layout
        let layout = picView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // 单张配图
        if count == 1 {
            // 取出图片
            let urlString = viewModel?.picURLs.last?.absoluteString
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(urlString)
            
            // 设置一张图片是layout的itemSize
            layout.itemSize = CGSize(width: image.size.width * 2, height: image.size.height * 2)
            
            return CGSize(width: image.size.width * 2, height: image.size.height * 2)
        }
        
        // 计算出来imageViewWH
        let imageViewWH = (UIScreen.mainScreen().bounds.width - 2 * edgeMargin - 2 * itemMargin) / 3
        
        // 设置其他张图片时layout的itemSize
        layout.itemSize = CGSize(width: imageViewWH, height: imageViewWH)
        
        // 四张配图
        if count == 4 {
            let picViewWH = imageViewWH * 2 + itemMargin + 1
            return CGSize(width: picViewWH, height: picViewWH)
        }
        
        // 其他张配图
        // 计算行数
        let rows = CGFloat((count - 1) / 3 + 1)
        
        // 计算picView的高度
        let picViewH = rows * imageViewWH + (rows - 1) * itemMargin
        
        // 计算picView的宽度
        let picViewW = UIScreen.mainScreen().bounds.width - 2 * edgeMargin
        
        return CGSize(width: picViewW, height: picViewH)
    }
}
