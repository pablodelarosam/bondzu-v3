//
//  CircledButton.swift
//  youcandoit
//
//  Created by Ricardo Lopez on 4/6/15.
//  Copyright (c) 2015 Ricardo Lopez. All rights reserved.
//  Archivo Localizado

import UIKit
import QuartzCore

@IBDesignable open class CircledButton: UIView {

    fileprivate var target : ((CircledButton)->Void)?
    var circleCenter = CGPoint.zero
    
    @IBInspectable open var color : UIColor = UIColor.clear{
        didSet{
            self.backgroundColor = color
        }
    }
    
    
    @IBInspectable open var borderColor : UIColor = UIColor.white{
        didSet{
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = 8
        }
    }
    
    
    @IBInspectable open var image : UIImage?{
        set(new){
            imageView.image = new
        }
        get{
            return imageView.image
        }

    }
    @IBInspectable open var border : CGFloat = 1
    open var text : String? {
        set(new){
            label.text = new
        }
        get{
            return label.text
        }
    }

    
    fileprivate var label : UILabel = UILabel()
    fileprivate var verifyCircle  = true
    fileprivate var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    
    func load(){
        self.clearsContextBeforeDrawing = false
        backgroundColor = UIColor.clear
        let tpg = UITapGestureRecognizer(target: self, action: #selector(CircledButton.tap(_:)))
        addGestureRecognizer(tpg)
        circleCenter = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        label.textAlignment = NSTextAlignment.center
        imageView.image = image
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        label.textColor = borderColor
        label.numberOfLines = 1
        label.font = label.font.withSize(10)
        label.textAlignment = NSTextAlignment.center
        
        self.layer.borderColor = self.color.cgColor
        
        addSubview(label)
        addSubview(imageView)
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = color

    }
    
    func setTargetAction(_ target : @escaping (CircledButton)->Void){
        self.target = target
    }
    
    override open func sizeToFit() {
        let d = min(frame.width, frame.height)
        frame.size = CGSize(width: d, height: d)
    }
    
    func tap( _ loc : UITapGestureRecognizer){
        
        if let delegate = target{
            
            if !verifyCircle{
                delegate(self)
                return
            }
            
            let point = loc.location(in: self)
            let v = sqrt(pow((point.x - circleCenter.x),2)+pow((point.y - circleCenter.y),2))
            if v < frame.width{
                delegate(self)
            }
        }
    }
    
    override open func layoutSubviews() {
        
        let border = frame.width * 0.10
        let contentSize = frame.width - border * 2
        
        let imageSpace = contentSize * 0.55
        let spaceBetweenViews = contentSize * 0.12
        let labelSpace = contentSize * 0.28

        imageView.frame = CGRect(origin: CGPoint(x: border , y: border + spaceBetweenViews), size: CGSize(width: frame.size.width -
            border * 2, height: imageSpace))

        
        label.frame = CGRect(origin: CGPoint(x: border + 3 , y: border + spaceBetweenViews + imageSpace), size: CGSize(width: frame.size.width - border * 2 - 6, height: labelSpace))
        
        Imagenes.redondeaVista(self, radio: self.frame.width / 2)
    }
}
