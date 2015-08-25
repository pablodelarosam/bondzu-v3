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

    public var target : ((CircledButton)->Void)?
    var circleCenter = CGPointZero
    
    @IBInspectable var color : UIColor = UIColor(red: 157/255, green: 219/255, blue: 218/255, alpha: 1)
    var label : UILabel = UILabel()
    var verifyCircle  = true

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
        addSubview(label)
    }
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(context, rect)
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
        label.frame = CGRect(origin:CGPointZero, size: frame.size)
    }
}
