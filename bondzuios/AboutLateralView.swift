//
//  AboutSegmentView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
// ARCHIVO LOCALIZADO

import UIKit

public class AboutLateralView: UIView {

    private var titleLabels = [UILabel]()
    private var separators = [UIView]()
    private var adoptersLabel = UILabel()
    private var eventImage = UIImageView()
    private var eventLabel = UILabel()
    public var moreButton = UIButton()
    
    
    public func setAdopters(adopters : Int){
        adoptersLabel.text = "\(adopters)"
    }
    
    public func getAdopters() -> Int?{
        return Int(adoptersLabel.text!)
    }
    
    var keeper1 : Usuario?{
        didSet{
            if let a = keeper1{
                keeperOneLabel.text = a.name
                if let b = a.image{
                    keeperOneImageView.image = b
                }
                self.setNeedsLayout()
            }
        }
    }
    
    var keeper2 : Usuario?{
        didSet{
            if let a = keeper2{
                keeperTwoLabel.text = a.name
                if let b = a.image{
                    keeperTwoImageView.image = b
                }
            }
            self.setNeedsLayout()

        }
    }
    
    var keeperOneImageView = UIImageView()
    var keeperTwoImageView = UIImageView()
    var keeperOneLabel = UILabel()
    var keeperTwoLabel = UILabel()
    
    func setEventData(image : UIImage? , title : String){
        eventImage.image = image
        eventLabel.text = title
        if image != nil{
            eventLabel.textAlignment = .Left
        }
        else{
            eventLabel.textAlignment = .Center
        }
        setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    
    func load(){
        for _ in 0..<2{
            let separator = UIView()
            separator.backgroundColor = UIColor.lightGrayColor()
            separator.frame.size.height = 1
            separator.frame.origin.x = 0
            separators.append(separator)
            addSubview(separator)
        }
        
        for _ in 0..<3{
            let label = UILabel()
            label.font = label.font.fontWithSize(16)
            label.textAlignment = NSTextAlignment.Center
            titleLabels.append(label)
            addSubview(label)
        }
        
        
        titleLabels[0].text = NSLocalizedString("Events", comment: "")
        titleLabels[1].text = NSLocalizedString("Keepers", comment: "")
        titleLabels[2].text = NSLocalizedString("Adopters", comment: "")
        
        adoptersLabel.text = "0"
        adoptersLabel.font = adoptersLabel.font.fontWithSize(35)
        adoptersLabel.textAlignment = NSTextAlignment.Center
        addSubview(adoptersLabel)
        
        
        keeperOneImageView.contentMode = UIViewContentMode.ScaleAspectFit
        keeperTwoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        addSubview(keeperOneImageView)
        addSubview(keeperTwoImageView)
        
        keeperOneLabel.textAlignment = NSTextAlignment.Center
        keeperTwoLabel.textAlignment = NSTextAlignment.Center
        keeperOneLabel.numberOfLines = 0
        keeperTwoLabel.numberOfLines = 0
        keeperOneLabel.font = keeperOneLabel.font.fontWithSize(10)
        keeperTwoLabel.font = keeperOneLabel.font
        addSubview(keeperOneLabel)
        addSubview(keeperTwoLabel)
        
        
        eventLabel.numberOfLines = 0
        eventLabel.font = eventLabel.font.fontWithSize(10)
        eventLabel.textAlignment = NSTextAlignment.Center
        addSubview(eventLabel)
        
        moreButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        moreButton.setTitle(NSLocalizedString("More", comment: ""), forState: .Normal)
        moreButton.titleLabel!.font = moreButton.titleLabel!.font.fontWithSize(7)
        addSubview(moreButton)
        
        addSubview(eventImage)

        eventLabel.text = NSLocalizedString("No events found", comment: "")
        eventLabel.backgroundColor = UIColor.clearColor()
    }
    
    public override func layoutSubviews() {
        
        //NOTA TODO FEATURE VERSION 2.0
        /*
        Arreglar problema que ocurre cuando la imagen del cuidador 2 de carga antes que la del cuidador 1
        */
        super.layoutSubviews()
        
        let width = frame.width
        let contentHeight = (frame.height - 6) / 3
        let secondFrameOriginY = contentHeight + 3
        let thirdFrameOriginY = secondFrameOriginY + contentHeight + 3
        
        let titleLabelHeight = contentHeight * 0.25
        let microContentHeight = contentHeight - titleLabelHeight
        
        
        for i in separators{
            i.frame.size.width = width
        }
        
        separators[0].frame.origin.y = contentHeight + 1
        separators[1].frame.origin.y = thirdFrameOriginY - 2
        
        titleLabels[0].frame = CGRect(x: 0, y: 0, width: width, height: titleLabelHeight)
        titleLabels[1].frame = CGRect(x: 0, y: secondFrameOriginY, width: width, height: titleLabelHeight)
        titleLabels[2].frame = CGRect(x: 0, y: thirdFrameOriginY, width: width, height: titleLabelHeight)
        
        adoptersLabel.frame = CGRect(x: 0, y: thirdFrameOriginY + titleLabelHeight + 5, width: width, height: microContentHeight - 5)
        
        let imageHeigth = (microContentHeight - 9) * 0.7
        
        
        if let _ = keeper1?.image{
            if let _ = self.keeper2?.image{
                let imageWidth = width / 2
                if(imageHeigth < imageWidth){
                    keeperOneImageView.frame.size = CGSize(width: imageHeigth, height: imageHeigth)
                    keeperTwoImageView.frame.size = CGSize(width: imageHeigth, height: imageHeigth)
                }
                else{
                    keeperOneImageView.frame.size = CGSize(width: imageWidth, height: imageWidth)
                    keeperTwoImageView.frame.size = CGSize(width: imageWidth, height: imageWidth)
                }
                
                keeperOneImageView.frame.origin = CGPoint(x: frame.size.width/4 - keeperOneImageView.frame.width / 2 , y: titleLabels[1].frame.origin.y + titleLabelHeight + 3)
                keeperOneLabel.frame = CGRect(x: 0, y: keeperOneImageView.frame.origin.y + keeperOneImageView.frame.height + 3 , width: imageWidth, height: microContentHeight - keeperOneImageView.frame.height - 9)
                Imagenes.redondeaVista(keeperOneImageView, radio: keeperOneImageView.frame.width / 2)
                
                keeperTwoImageView.frame.origin = CGPoint(x: frame.size.width/4 * 3 - keeperOneImageView.frame.width / 2 , y: titleLabels[1].frame.origin.y + titleLabelHeight + 3)
                keeperTwoLabel.frame = CGRect(x: frame.width / 2, y: keeperOneImageView.frame.origin.y + keeperOneImageView.frame.height + 3 , width: imageWidth, height: microContentHeight - keeperOneImageView.frame.height - 9)
                Imagenes.redondeaVista(keeperTwoImageView, radio: keeperOneImageView.frame.width / 2)
                
                
            }
            else{
                let imageWidth = width
                if(imageHeigth < imageWidth){
                    keeperOneImageView.frame.size = CGSize(width: imageHeigth, height: imageHeigth)
                }
                else{
                    keeperOneImageView.frame.size = CGSize(width: imageWidth, height: imageWidth)
                }
                
                keeperOneImageView.frame.origin = CGPoint(x: width / 2 - keeperOneImageView.frame.width / 2, y: titleLabels[1].frame.origin.y + titleLabelHeight + 3)
                keeperOneLabel.frame = CGRect(x: 0, y: keeperOneImageView.frame.origin.y + keeperOneImageView.frame.height + 3 , width: width, height: microContentHeight - keeperOneImageView.frame.height - 9)
                
                Imagenes.redondeaVista(keeperOneImageView, radio: keeperOneImageView.frame.width / 2)
            }
        }
        
        if let _ = eventImage.image{
            
            let availableWidth = frame.width / 2
            eventLabel.frame = CGRect(x: frame.width / 2 + 1, y: titleLabelHeight + 3, width: availableWidth - 2, height: microContentHeight - 6)
            let imgSize = min(availableWidth, microContentHeight)
            eventImage.frame = CGRect(x: width / 4 - imgSize / 2, y: titleLabelHeight + (microContentHeight - imgSize) / 2 , width:imgSize, height: imgSize)
            Imagenes.redondeaVista(eventImage, radio: imgSize / 2)
            
            moreButton.frame.size = CGSize(width: 30, height: 15)
            moreButton.frame.origin = CGPoint(x: width - moreButton.frame.width, y: microContentHeight + titleLabelHeight - moreButton.frame.height)
            
            eventLabel.textColor = UIColor.blackColor()
            moreButton.hidden = false
        }
        else{
            eventLabel.frame = CGRect(x: 0, y: titleLabelHeight, width: width, height: microContentHeight)
            eventLabel.textColor = UIColor.lightGrayColor()
            moreButton.hidden = true
        }
    }
    
    
    @available(*, deprecated=8.0, message="This method was deprecated for a new api that takes a completed flag. Use photoDidLoad instead")
    func photoReady( user : Usuario){
        if(user == keeper1){
            keeperOneImageView.image = keeper1?.image
        }
        else if(user == keeper2){
            keeperTwoImageView.image = keeper2?.image
        }
        setNeedsLayout()
    }
    
    //WARNING: Incomplete implementation
    func photoDidLoad( user : Usuario, completed : Bool){
        if(user == keeper1){
            keeperOneImageView.image = keeper1?.image
        }
        else if(user == keeper2){
            keeperTwoImageView.image = keeper2?.image
        }
        setNeedsLayout()
    }

    
}
