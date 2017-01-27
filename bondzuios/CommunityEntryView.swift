//
//  CommunityEntryView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/3/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit

@objc protocol CommunitEntryEvent{
    
    //Funcion que informa cuando alguien da like
    func like(_ message : Message, like : Bool)
    
    //Funcion que informa cuando alguien da like
    func imageSelected(_ message : Message)
    
    //Funcion que informa cuando alguien da report
    func report(_ message : Message)
    
    //Funcion que informa cuando alguien da reply
    func reply(_ message : Message)
}


class CommunityEntryView: UITableViewCell {

    var commentID : Message!
    
    let heartImageView = UIImageView()
    let profileIcon = UserView()
    let imageIcon = UIImageView()
    
    let separator = UIView()
    
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let commentLabel = UILabel()
    let likesLabel = UILabel()

    
    let replyButton = UIButton()
    let reportButton = UIButton()

    var likeCount = 0;

    
    weak var delegate : CommunitEntryEvent?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        load()
    }
    
    func setInfo(_ id : Message, date : Date, name : String, message : String, image : UIImage?, hasContentImage : Bool = false , hasLiked : Bool = false, likeCount : Int, user : Usuario?){
        
        imageIcon.isHidden = !hasContentImage
        
        commentID = id
        
        nameLabel.text = name
        commentLabel.text = message
        
        profileIcon.image = image
        
        imageIcon.isHidden = !hasContentImage
        
        self.likeCount = likeCount
        
        var text = ""
        var i : Double = Double(likeCount)
        
        if i >= 1000{
            while(i >= 1000){
                text = "\(text)k"
                i /= 1000
            }
            text = "\(i)k"
        }
        else{
            text = "\(Int(i))"
        }
        likesLabel.text = text
        
        let now = Date()
        let seconds = now.timeIntervalSince(date)
        
        if seconds < 86400{
            timeLabel.text = NSLocalizedString("Today", comment: "")
        }
        else{
            let days = Int(seconds / 86400)
            timeLabel.text = "\(days) " + (days == 1 ? NSLocalizedString("day ago", comment: "") : NSLocalizedString("days ago", comment: ""))
        }
        
        heartImageView.isHighlighted = hasLiked
    
        isHidden = false
        setNeedsLayout()
    }
    
    func load(){
        
        isHidden = true
        
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.image = UIImage(named: "like")
        heartImageView.highlightedImage = UIImage(named: "like_selected")
        addSubview(heartImageView)
        
        profileIcon.contentMode = .scaleAspectFill
        addSubview(profileIcon)
        
        imageIcon.contentMode = .scaleAspectFit
        imageIcon.isHidden = true
        imageIcon.image = UIImage(named: "imageIcon")
        addSubview(imageIcon)
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        nameLabel.numberOfLines = 1
        addSubview(nameLabel)
        
        timeLabel.numberOfLines = 1
        timeLabel.font = nameLabel.font.withSize(nameLabel.font.pointSize - 2)
        timeLabel.textColor = UIColor.lightGray
        timeLabel.adjustsFontSizeToFitWidth = true
        addSubview(timeLabel)
        
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        commentLabel.adjustsFontSizeToFitWidth = true
        addSubview(commentLabel)
        
        likesLabel.font = commentLabel.font.withSize(commentLabel.font.pointSize - 5)
        likesLabel.numberOfLines = 1
        likesLabel.textColor = UIColor.lightGray
        likesLabel.textAlignment = .center
        likesLabel.adjustsFontSizeToFitWidth = true
        addSubview(likesLabel)
    
        replyButton.setTitle(NSLocalizedString("Reply", comment: ""), for: UIControlState())
        replyButton.titleLabel?.font = likesLabel.font
        replyButton.tintColor = UIColor.lightGray
        replyButton.setTitleColor(UIColor.lightGray, for: UIControlState())
        replyButton.addTarget(self, action: #selector(CommunityEntryView.reply), for: UIControlEvents.touchUpInside)
        addSubview(replyButton)

        reportButton.setTitle(NSLocalizedString("Report", comment: ""), for: UIControlState())
        reportButton.titleLabel?.font = likesLabel.font
        reportButton.tintColor = UIColor.lightGray
        reportButton.setTitleColor(UIColor.lightGray, for: UIControlState())
        addSubview(reportButton)
        
        separator.backgroundColor = UIColor.lightGray
        addSubview(separator)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CommunityEntryView.like))
        heartImageView.addGestureRecognizer(gesture)
        heartImageView.isUserInteractionEnabled = true
        
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(CommunityEntryView.imageTaped))
        imageIcon.addGestureRecognizer(gesture2)
        imageIcon.isUserInteractionEnabled = true
        
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(CommunityEntryView.report))
        reportButton.addGestureRecognizer(gesture3)
    }
    
    func like(){
        heartImageView.isHighlighted = !heartImageView.isHighlighted
        delegate?.like(commentID, like: heartImageView.isHighlighted)
    }
    
    func imageTaped(){
        delegate?.imageSelected(commentID)
    }
    
    func report(){
        delegate?.report(commentID)
    }
    
    override func layoutSubviews() {
        let x0 = frame.width * 0.03
        let imageWidth = frame.width * 0.2

        //Hay tres paddings (x0) al inicio, entre la imagen, las label con la imagen y las label con like
        let likesImageWidth = frame.width * 0.1
        let endPadding = frame.width * 0.1
        let viewIconWidth : CGFloat = imageIcon.isHidden ? 0 : likesImageWidth

        let contentSizeWidth = frame.width - x0 * (imageIcon.isHidden ? 3 : 4) - imageWidth - endPadding - viewIconWidth - likesImageWidth
        
        let imageIconDimention = min(imageWidth , (frame.height - 2))
        
        profileIcon.frame = CGRect(x: x0 + imageWidth / 2 - imageIconDimention / 2, y: frame.height / 2 - imageIconDimention / 2, width: imageIconDimention, height: imageIconDimention)
        Imagenes.redondeaVista(profileIcon, radio: imageIconDimention / 2)
        
        heartImageView.frame = CGRect(x: frame.width - likesImageWidth - endPadding, y: frame.height / 2 - 10, width: frame.height * 0.3 , height: frame.height * 0.3)
        
        if !imageIcon.isHidden{
            imageIcon.frame = CGRect(x: heartImageView.frame.origin.x - x0 - heartImageView.frame.width, y: frame.height / 2 - 10, width: frame.height * 0.3 , height: frame.height * 0.3)
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
        
        if nameLabel.frame.width + timeLabel.frame.width > contentSizeWidth + likesImageWidth + viewIconWidth{
            nameLabel.frame.size.width = contentSizeWidth * 0.65
            timeLabel.frame.size.width = contentSizeWidth * 0.35
            timeLabel.frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.width
            nameLabel.adjustsFontSizeToFitWidth = true
        }
        
    }
    
    func reply(){
        delegate?.reply(commentID)
    }
}

//TODO Ver porque el loading no funciona bajo ciertas condiciones
//Animales que si tienen mensajes
