//
//  Transaction.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/5/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse
class Transaction: NSObject {

    var delegate : TransactionLoadingDelegate?
    
    var transaction : PFObject
    var animal : AnimalV2!

    var itemDescrption : String!
    
    var loaded = false
    
    
    var price : Int{
        return transaction["precio"] as! Int
    }
    
    var date : NSDate{
        get{
            return transaction.createdAt!
        }
    }
    
    var loadingObserver : TransactionLoadingDelegate?
    
    init?(object : PFObject){
        transaction = object
        super.init()
                
        let producto = transaction["productoid"] as! PFObject
        producto.fetchIfNeededInBackgroundWithBlock {
            (productoObtenido, error) -> Void in
            if error == nil && productoObtenido != nil{
                self.itemDescrption = productoObtenido!["nombre"] as! String
                if let animal = productoObtenido!["animal_Id"] as? PFObject{
                    animal.fetchIfNeededInBackgroundWithBlock({ (animal, error) -> Void in
                        
                        guard error == nil else{
                            print("Error al obtener al animal")
                            self.delegate?.transaccionDidFailLoading(self)
                            return
                        }
                        
                        let animalV2 = AnimalV2()
                        animalV2.name = animal!["name"] as! String
                        animalV2.objectId = animal!.objectId!
                        self.animal = animalV2
                        let file = animal!["profilePhoto"] as! PFFile
                        file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error == nil && data != nil{
                                let image = UIImage(data: data!)
                                animalV2.image = image
                                self.loaded = true
                                self.delegate?.transaccionDidFinishLoading(self)
                            }
                            else{
                                self.delegate?.transaccionDidFailLoading(self)
                                self.delegate = nil
                            }
                        })
                        
                    })
                    
                }
                else{
                    print("El item elegido no tiene animal. Descartado")
                    self.delegate?.transaccionDidFailLoading(self)
                    self.delegate = nil
                }
                
            }
            else{
                self.delegate?.transaccionDidFailLoading(self)
                self.delegate = nil
            }
        }
        
    }
    
   
}

protocol TransactionLoadingDelegate{
    func transaccionDidFinishLoading(t : Transaction?)
    func transaccionDidFailLoading(t : Transaction?)
}
