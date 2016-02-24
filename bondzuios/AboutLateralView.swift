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

    private let sections : CGFloat = 2
    
    /// The array containing the title label of each section
    private var titleLabels = [UILabel]()
    
    /// The UIViews that work as separator
    private var separator = UIView()
    
    /// The label that displays the number of adopters
    private var adoptersLabel = UILabel()
    

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

        separator.backgroundColor = UIColor.lightGrayColor()
        separator.frame.size.height = 1
        separator.frame.origin.x = 0
        addSubview(separator)
        
        
        for _ in 0..<2{
            let label = UILabel()
            label.font = label.font.fontWithSize(16)
            label.textAlignment = NSTextAlignment.Center
            titleLabels.append(label)
            addSubview(label)
        }
        
        
        titleLabels[0].text = NSLocalizedString("Keepers", comment: "")
        titleLabels[1].text = NSLocalizedString("Adopters", comment: "")
        
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
        
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let width = frame.width
        let contentHeight = (frame.height - 6) / sections
        let secondFrameOriginY = contentHeight + 3
        
        let titleLabelHeight = contentHeight * 0.25
        let microContentHeight = contentHeight - titleLabelHeight
        
        separator.frame.size.width = width
        
        separator.frame.origin.y = contentHeight + 1
        
        titleLabels[0].frame = CGRect(x: 0, y: 0, width: width, height: titleLabelHeight)
        titleLabels[1].frame = CGRect(x: 0, y: secondFrameOriginY, width: width, height: titleLabelHeight)
        
        adoptersLabel.frame = CGRect(x: 0, y: secondFrameOriginY + titleLabelHeight + 5, width: width, height: microContentHeight - 5)
        
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
    }
    
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
