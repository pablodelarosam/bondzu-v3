//
//  CircledButton.swift
//  youcandoit
//
//  Created by Ricardo Lopez on 4/6/15.
//  Copyright (c) 2015 Ricardo Lopez. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable public class CircledButton: UIView {

    //TODO Analizar posible referencia circular
    public var target : ((CircledButton)->Void)?
    var circleCenter = CGPointZero
    
    @IBInspectable public var color : UIColor = UIColor.clearColor()
    @IBInspectable public var borderColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var image : UIImage?{
        set(new){
            imageView.image = new
        }
        get{
            return imageView.image
        }

    }
    @IBInspectable public var border : CGFloat = 1
    public var text : String? {
        set(new){
            label.text = new
        }
        get{
            return label.text
        }
    }

    
    private var label : UILabel = UILabel()
    private var verifyCircle  = true
    private var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    
    func load(){
        backgroundColor = UIColor.clearColor()
        let tpg = UITapGestureRecognizer(target: self, action: "tap:")
        addGestureRecognizer(tpg)
        circleCenter = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        label.textAlignment = NSTextAlignment.Center
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        label.textColor = borderColor
        label.numberOfLines = 1
        label.font = label.font.fontWithSize(10)
        label.textAlignment = NSTextAlignment.Center
        addSubview(label)
        addSubview(imageView)
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, border)
        CGContextAddEllipseInRect(context, CGRect(x: rect.origin.x + border, y: rect.origin.y + border, width: rect.size.width - border - border, height: rect.size.height - border - border))
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        
        CGContextStrokePath(context)
        
        CGContextAddEllipseInRect(context, CGRect(x: rect.origin.x + border, y: rect.origin.y + border, width: rect.size.width - border - border, height: rect.size.height - border - border))
        CGContextSetFillColor(context, CGColorGetComponents(color.CGColor));
        CGContextFillPath(context)
        
    }
    
    func setTargetAction(target : (CircledButton)->Void){
        self.target = target
    }
    
    override public func sizeToFit() {
        let d = min(frame.width, frame.height)
        frame.size = CGSize(width: d, height: d)
    }
    
    func tap( loc : UITapGestureRecognizer){
        
        if let delegate = target{
            
            if !verifyCircle{
                delegate(self)
                return
            }
            
            let point = loc.locationInView(self)
            let v = sqrt(pow((point.x - circleCenter.x),2)+pow((point.y - circleCenter.y),2))
            if v < frame.width{
                delegate(self)
            }
        }
    }
    
    override public func layoutSubviews() {
        
        let border = frame.width * 0.10
        
        let contentSize = frame.width - border * 2
        
        
        let imageSpace = contentSize * 0.55
        let spaceBetweenViews = contentSize * 0.12
        let labelSpace = contentSize * 0.28

        imageView.frame = CGRect(origin: CGPoint(x: border , y: border + spaceBetweenViews), size: CGSize(width: frame.size.width -
            border * 2, height: imageSpace))

        
        label.frame = CGRect(origin: CGPoint(x: border + 3 , y: border + spaceBetweenViews + imageSpace), size: CGSize(width: frame.size.width - border * 2 - 6, height: labelSpace))
    }
}
