//
//  CommunityReplyEntryCellTableViewCell.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class CommunityReplyEntryCellTableViewCell: UITableViewCell {

    var commentID = ""
    
    let profileIcon = UIImageView()
    
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let commentLabel = UILabel()
    
    var likeCount = 0;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        load()
    }
    
    
    func setInfo(id : String , date : NSDate, name : String, message : String, image : UIImage?){
        
        commentID = id
        
        nameLabel.text = name
        commentLabel.text = message
        
        profileIcon.image = image
        
        let now = NSDate()
        let seconds = now.timeIntervalSinceDate(date)
        
        if seconds < 86400{
            timeLabel.text = "today"
        }
        else{
            let days = Int(seconds / 86400)
            timeLabel.text = "\(days) " + (days == 1 ? "day ago" : "days ago")
        }
        
        hidden = false
        setNeedsLayout()
    }
    
    func load(){
        
        hidden = true
        
        profileIcon.contentMode = .ScaleAspectFill
        addSubview(profileIcon)
        
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.numberOfLines = 0
        addSubview(nameLabel)
        
        timeLabel.numberOfLines = 0
        timeLabel.font = nameLabel.font.fontWithSize(nameLabel.font.pointSize - 2)
        timeLabel.textColor = UIColor.lightGrayColor()
        timeLabel.adjustsFontSizeToFitWidth = true
        addSubview(timeLabel)
        
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        commentLabel.adjustsFontSizeToFitWidth = true
        addSubview(commentLabel)
    }
    
    
    override func layoutSubviews() {
        let x0 = frame.width * 0.15
        let availableWidth = frame.width - x0
        
        let padding = availableWidth * 0.03
        
        
        let imageWidth = availableWidth * 0.2
        let endPadding = availableWidth * 0.1
        
        let contentSizeWidth = availableWidth - padding - imageWidth - endPadding
        let imageIconDimention = min(imageWidth , (frame.height - 2))
        
        profileIcon.frame = CGRect(x: x0 + imageWidth / 2 - imageIconDimention / 2, y: frame.height / 2 - imageIconDimention / 2, width: imageIconDimention, height: imageIconDimention)
        Imagenes.redondeaVista(profileIcon, radio: imageIconDimention / 2)
        
        let upPadding = frame.height * 0.1
        let nameHeigth = frame.height * 0.45
        let messageHeight = frame.height * 0.35
        
        nameLabel.frame = CGRect(x: profileIcon.frame.origin.x + profileIcon.frame.width + padding, y: upPadding, width: contentSizeWidth, height: nameHeigth)
        nameLabel.sizeToFit()
        timeLabel.frame.size = CGSize(width: frame.width, height: nameHeigth)
        timeLabel.sizeToFit()
        timeLabel.frame.origin = CGPoint(x: nameLabel.frame.origin.x + nameLabel.frame.width + padding / 2, y: nameLabel.frame.origin.y + nameLabel.frame.height - timeLabel.frame.height)
        commentLabel.frame = CGRect(x: nameLabel.frame.origin.x, y: nameLabel.frame.origin.y + nameLabel.frame.size.height, width: contentSizeWidth, height: messageHeight)
        
        
    }


}
