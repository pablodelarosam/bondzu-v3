//
//  UserView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/26/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class UserView : CircledImageView {
    
    
    private let paw = UIImageView( image: (UIImage(named: "whitePaw")!).imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))

     var user : Usuario?{
        didSet{
            if user == nil{
                paw.hidden = true
            }
            else{
                paw.hidden = false
                
                user?.appendTypeLoadingObserver({
                    [weak self]
                    (u, _) -> (Bool) in
                    
                    guard let s = self where s.user == u else{
                        return false
                    }
                    
                    if u.hasLoadedPriority{
                        s.loadPaw()
                    }
                    return true
                })
                
                if user!.hasLoadedPriority{
                    loadPaw()
                }
                
            }
        }
    }
    
    private func loadPaw(){
        
        guard user != nil && user!.hasLoadedPriority else{
            return
        }
        
        paw.tintColor = user!.type!.color
        self.setBorderOfColor(user!.type!.color, width: 3)
    }
    
    override func layoutSubviews() {
        paw.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        super.layoutSubviews()
    }
    
}
