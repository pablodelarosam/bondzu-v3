//
//  Transaction.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/5/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado


import UIKit
import Parse
class Transaction: NSObject, AnimalV2LoadingProtocol{

    var delegate : TransactionLoadingDelegate?
    
    var transaction : PFObject
    var animal : AnimalV2!
    var itemDescrption : String!
    var loaded = false
    
    
    var price : Int{
        return transaction[TableTransactionColumnNames.Price.rawValue] as! Int
    }
    
    var date : NSDate{
        get{
            return transaction.createdAt!
        }
    }
    
    var loadingObserver : TransactionLoadingDelegate?
    
    init(object : PFObject, delegate : TransactionLoadingDelegate?){

        transaction = object
        self.delegate = delegate
        super.init()
        let producto = transaction[TableTransactionColumnNames.Product.rawValue] as! PFObject
        producto.fetchIfNeededInBackgroundWithBlock {
            (productoObtenido, error) -> Void in
            if error == nil && productoObtenido != nil{
                self.itemDescrption = productoObtenido![TableProductColumnNames.Name.rawValue + NSLocalizedString(LOCALIZED_STRING, comment: "")] as! String
                if let animal = productoObtenido![TableProductColumnNames.AnimalID.rawValue] as? PFObject{
                    dispatch_async(Constantes.get_bondzu_queue()){
                        [weak self]
                        in
                        do{
                            try animal.fetchIfNeeded()
                            if self == nil{
                                return
                            }
                            
                            dispatch_async(dispatch_get_main_queue()){
                                _ = AnimalV2(object: animal, delegate: self)
                            }
                            
                        }
                        catch{
                            dispatch_async(dispatch_get_main_queue()){
                                self?.delegate?.transaccionDidFailLoading(self)
                            }
                        }
                    }
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
    
    func animalDidFinishLoading(animal : AnimalV2){
        self.animal = animal
        self.delegate?.transaccionDidFinishLoading(self)
    }
    
    func animalDidFailLoading(animal : AnimalV2){
        print("Error al obtener al animal")
        self.delegate?.transaccionDidFailLoading(self)
    }

    class func createInParse( user : Usuario, product : Producto,  transactionID : String, description : String, price : NSNumber){
        let object = PFObject(className: TableNames.Transactions_table.rawValue)
        object[TableTransactionColumnNames.User.rawValue] = user.originalObject
        object[TableTransactionColumnNames.Product.rawValue] = product.originalObject
        object[TableTransactionColumnNames.Transaction.rawValue] = transactionID
        object[TableTransactionColumnNames.Description.rawValue] = description
        object[TableTransactionColumnNames.Price.rawValue] = price
        object.saveInBackground()
    }
    
    
    //TODO: Empty implementation
    func animalDidFinishLoadingPermissionType(animal: AnimalV2) {
        
    }
    
    func animalDidFailedLoadingPermissionType(animal: AnimalV2) {
        
    }
}

protocol TransactionLoadingDelegate{
    func transaccionDidFinishLoading(t : Transaction?)
    func transaccionDidFailLoading(t : Transaction?)
}
