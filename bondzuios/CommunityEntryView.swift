//
//  CommunityEntryView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/3/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class CommunityEntryView: UIView {

    var commentID = ""
    
    let heartImageView = UIImageView()
    let profileIcon = UIImageView()
    let imageIcon = UIImageView()
    
    let separator = UIView()
    
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let commentLabel = UILabel()
    let likesLabel = UILabel()

    
    let replyButton = UIButton()
    let reportButton = UIButton()

    var likeCount = 0;

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    
    func setInfo(id : String , date : NSDate, name : String, message : String, image : UIImage?, hasContentImage : Bool = false , hasLiked : Bool = false, likeCount : Int){
        
        imageIcon.hidden = !hasContentImage
        
        commentID = id
        
        nameLabel.text = name
        commentLabel.text = message
        
        profileIcon.image = image
        
        imageIcon.hidden = !hasContentImage
        
        self.likeCount = likeCount
        
        var text = ""
        var i : Double = Double(likeCount)
        while(i >= 1000){
            text = "\(text)k"
            i /= 1000
        }
        text = "\(i)k"
        
        likesLabel.text = text
        
        let now = NSDate()
        let seconds = now.timeIntervalSinceDate(date)
        
        if seconds < 86400{
            timeLabel.text = "today"
        }
        else{
            let days = Int(seconds / 86400)
            timeLabel.text = "\(days) " + (days == 1 ? "day ago" : "days ago")
        }
        
        heartImageView.highlighted = hasLiked
    
        hidden = false
        setNeedsLayout()
    }
    
    func load(){
        
        hidden = true
        
        heartImageView.contentMode = .ScaleAspectFit
        heartImageView.image = UIImage(named: "like")
        heartImageView.highlightedImage = UIImage(named: "like_selected")
        addSubview(heartImageView)
        
        profileIcon.contentMode = .ScaleAspectFill
        addSubview(profileIcon)
        
        imageIcon.contentMode = .ScaleAspectFit
        imageIcon.hidden = true
        imageIcon.image = UIImage(named: "imageIcon")
        addSubview(imageIcon)
        
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.numberOfLines = 0
        addSubview(nameLabel)
        
        timeLabel.numberOfLines = 0
        timeLabel.font = nameLabel.font.fontWithSize(nameLabel.font.pointSize - 2)
        timeLabel.textColor = UIColor.lightGrayColor()
        addSubview(timeLabel)
        
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        addSubview(commentLabel)
        
        likesLabel.font = commentLabel.font.fontWithSize(commentLabel.font.pointSize - 5)
        likesLabel.numberOfLines = 0
        likesLabel.textColor = UIColor.lightGrayColor()
        likesLabel.textAlignment = .Center
        addSubview(likesLabel)
    
        replyButton.setTitle("Reply", forState: .Normal)
        replyButton.titleLabel?.font = likesLabel.font
        replyButton.tintColor = UIColor.lightGrayColor()
        replyButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        addSubview(replyButton)

        reportButton.setTitle("Report", forState: .Normal)
        reportButton.titleLabel?.font = likesLabel.font
        reportButton.tintColor = UIColor.lightGrayColor()
        reportButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        addSubview(reportButton)
        
        separator.backgroundColor = UIColor.lightGrayColor()
        addSubview(separator)
    }
    
    override func layoutSubviews() {
        let x0 = frame.width * 0.03
        let imageWidth = frame.width * 0.14

        //Hay tres paddings (x0) al inicio, entre la imagen, las label con la imagen y las label con like
        let likesImageWidth = frame.width * 0.1
        let endPadding = frame.width * 0.1
        let viewIconWidth : CGFloat = imageIcon.hidden ? 0 : likesImageWidth

        let contentSizeWidth = frame.width - x0 * (imageIcon.hidden ? 3 : 4) - imageWidth - endPadding - viewIconWidth - likesImageWidth
        
        let imageIconDimention = max(imageWidth * 0.7, (frame.height - 6) * 0.7)
        
        profileIcon.frame = CGRect(x: x0 + imageWidth / 2 - imageIconDimention / 2, y: frame.height / 2 - imageIconDimention / 2, width: imageIconDimention, height: imageIconDimention)
        Imagenes.redondeaVista(profileIcon, radio: imageIconDimention / 2)
        
        heartImageView.frame = CGRect(x: frame.width - likesImageWidth - endPadding, y: frame.height / 2 - 10, width: frame.height * 0.3 , height: frame.height * 0.3)
        
        if !imageIcon.hidden{
            imageIcon.frame = CGRect(x: heartImageView.frame.origin.x - x0 - imageIcon.frame.width, y: frame.height / 2 - 10, width: frame.height * 0.3 , height: frame.height * 0.3)
        }
        
        
        likesLabel.frame = CGRect(x: frame.width - likesImageWidth - endPadding, y: heartImageView.frame.origin.y + heartImageView.frame.height, width: heartImageView.frame.width, height: frame.height * 0.2)
        
        separator.frame = CGRect(x: 3, y: frame.height - 1, width: frame.width - 6, height: 1)
        
        let upPadding = frame.height * 0.1
        let nameHeigth = frame.height * 0.35
        let messageHeight = frame.height * 0.3
        let buttonsHeight = frame.height * 0.2
        
        nameLabel.frame = CGRect(x: profileIcon.frame.origin.x + profileIcon.frame.width + x0, y: upPadding, width: contentSizeWidth, height: nameHeigth)
        nameLabel.sizeToFit()
        timeLabel.frame.size = CGSize(width: frame.width, height: nameHeigth)
        timeLabel.sizeToFit()
        timeLabel.frame.origin = CGPoint(x: nameLabel.frame.origin.x + nameLabel.frame.width + x0 / 2, y: nameLabel.frame.origin.y + nameLabel.frame.height - timeLabel.frame.height)
        commentLabel.frame = CGRect(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height, width: contentSizeWidth, height: messageHeight)
        
        replyButton.frame.size = replyButton.sizeThatFits(CGSize(width: contentSizeWidth * 0.5, height: buttonsHeight))
        replyButton.frame.origin = CGPoint(x: nameLabel.frame.origin.x, y: frame.height - replyButton.frame.height - 3)
        
        reportButton.frame.size = reportButton.sizeThatFits(CGSize(width: contentSizeWidth * 0.5, height: buttonsHeight))
        reportButton.frame.origin = CGPoint(x: replyButton.frame.origin.x + contentSizeWidth * 0.5, y: frame.height - replyButton.frame.height - 3)
        
       
    }
}