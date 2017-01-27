//
//  LoadingView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/17/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit

class LoadingView: UIView {

    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let outView = UIView()
    let inView = UIView()
    
    init(view : UIView){
        super.init(frame: view.frame)

        activity.color = UIColor.white
    
        outView.backgroundColor = UIColor.gray
        outView.alpha = 0.5
        
        inView.backgroundColor = UIColor.darkGray
        inView.alpha = 0.8
        
        activity.startAnimating()
        
        addSubview(outView)
        addSubview(inView)
        addSubview(activity)
        view.addSubview(self)
    }

    func finish(){
        activity.stopAnimating()
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let view = superview!
        inView.frame = CGRect(x: view.frame.width / 2 - 50, y: view.frame.height / 2 - 50, width: 100, height: 100)
        outView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        activity.frame = CGRect(x: view.frame.width / 2 - 25, y: view.frame.height / 2 - 25, width: 50, height: 50)
        inView.layer.cornerRadius = 10
    }

}
