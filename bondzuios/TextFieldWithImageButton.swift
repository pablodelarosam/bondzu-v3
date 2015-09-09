//
//  TextFieldWithImageButton.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

protocol TextFieldWithImageButtonProtocol{

    func pressedButton()

    func sendButtonPressed()
    
    
}

class TextFieldWithImageButton: UIView, UITextFieldDelegate  {

    var imageView = UIImageView()
    var text = UITextField()
    var paddingLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
    var paddingRightView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))

    
    var delegate : TextFieldWithImageButtonProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func load(){
        
        imageView.image = UIImage(named: "camera_icon")
        text.placeholder = "Share your thoughts..."
        
        backgroundColor = UIColor.lightGrayColor()
        text.backgroundColor = UIColor.whiteColor()

        text.leftViewMode = .Always
        text.leftView = paddingLeftView
        text.rightViewMode = .Always
        text.rightView = paddingRightView
        text.delegate = self
        
        let gr = UITapGestureRecognizer(target: self, action: "buttonPressed")
        imageView.addGestureRecognizer(gr)
        imageView.userInteractionEnabled = true
        
        addSubview(text)
        addSubview(imageView)
        
    }
    
    
    override func layoutSubviews(){
        paddingRightView.frame.size.width = frame.height
        text.frame = CGRect(x: 3, y: 2, width: frame.width - 6, height: frame.height - 4)
        text.layer.cornerRadius = text.frame.height / 2
        imageView.frame = CGRect(x: frame.width - frame.height - 6, y: 3, width: frame.height - 6, height: frame.height - 6)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        text.resignFirstResponder()
        delegate?.sendButtonPressed()
        return true
    }
    
    func buttonPressed(){
        text.resignFirstResponder()
        delegate?.pressedButton()
    }
    
    
    
}
