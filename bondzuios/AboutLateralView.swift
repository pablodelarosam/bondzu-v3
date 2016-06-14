//
//  AboutSegmentView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
// ARCHIVO LOCALIZADO

import UIKit

/**
 This class provides the rigth lateral view on the about.
 */
public class AboutLateralView: UIView {

    //DH 2 -> 3
    private let sections : CGFloat = 3
    
    /// The array containing the title label of each section
    private var titleLabels = [UILabel]()
    
    
    /// The UIViews that work as separator
    //DWH
    private var separators = [UIView]()
    
    /// The label that displays the number of adopters
    private var adoptersLabel = UILabel()
    
    //DWH
    private var eventImage = UIImageView()
    private var eventLabel = UILabel()
    public var moreButton = UIButton()

    /**
     This method should be called when the number of adopters has been loaded.
     
     - parameter adopters: The number of adopters that the animal has
     */
    public func setAdopters(adopters : Int){
        adoptersLabel.text = "\(adopters)"
    }
    
    /**
     This method returns the reported number of adopters that was given to this class
     
     - returns: The int value reported to this function or nil if there was an error
     */
    public func getAdopters() -> Int?{
        return Int(adoptersLabel.text!)
    }
    
    /// The left keeper
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
    
    /// The right keeper
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
    
    /// The image view that encloses the first keeper image
    private var keeperOneImageView = UIImageView()
    /// The image that encloses the second keeper image
    private var keeperTwoImageView = UIImageView()

    /// The label that displays the first keeper name
    private var keeperOneLabel = UILabel()
    /// The label that displays the second keeper name
    private var keeperTwoLabel = UILabel()
    

    //DWH
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
    
    
    /**
     This method is called by the constructors to set the properties to a valid initial state
     */
    private func load(){

        //DWH
        for _ in 0..<2{
            let separator = UIView()
            separator.backgroundColor = UIColor.lightGrayColor()
            separator.frame.size.height = 1
            separator.frame.origin.x = 0
            separators.append(separator)
            addSubview(separator)
        }
        
        //DWH 2 -> 3
        for _ in 0..<3{
            let label = UILabel()
            label.font = label.font.fontWithSize(16)
            label.textAlignment = NSTextAlignment.Center
            titleLabels.append(label)
            addSubview(label)
        }
        
        //DWH
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
        
        
        //DWH
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
        
        self.setNeedsLayout()
        
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let width = frame.width
        let contentHeight = (frame.height - 6) / sections
        let secondFrameOriginY = contentHeight + 3
        //DWH
        let thirdFrameOriginY = secondFrameOriginY + contentHeight + 3

        
        let titleLabelHeight = contentHeight * 0.25
        let microContentHeight = contentHeight - titleLabelHeight
        
        //DWH
        for i in separators{
            i.frame.size.width = width
        }
        
        separators[0].frame.origin.y = contentHeight + 1
        //DWH
        separators[1].frame.origin.y = thirdFrameOriginY - 2

        
        titleLabels[0].frame = CGRect(x: 0, y: 0, width: width, height: titleLabelHeight)
        titleLabels[1].frame = CGRect(x: 0, y: secondFrameOriginY, width: width, height: titleLabelHeight)
        //DWH
        titleLabels[2].frame = CGRect(x: 0, y: thirdFrameOriginY, width: width, height: titleLabelHeight)
        
        adoptersLabel.frame = CGRect(x: 0, y: thirdFrameOriginY + titleLabelHeight + 5, width: width, height: microContentHeight - 5)
        
        let imageHeigth = (microContentHeight - 9) * 0.7
        
        
        if let _ = self.keeper1{
            if let _ = self.keeper2{
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
        
        //DWH
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
    
    //igual
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
