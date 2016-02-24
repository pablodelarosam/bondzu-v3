//
//  Constantes.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 13/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import UIKit

#if DEBUG
    enum PFCloudFunctionNames : String{
        case ListCards = "listCards_test"
        case DeleteCard = "deleteCard_test_test"
        case CreateCard = "createCard_test"
        case CreateCharge = "createCharge_test"
        case CreateChargeExistingCard = "createChargeExistingCard_test"
        case CreateCustomer = "createCustomer_test"
        
    }
#else
    enum PFCloudFunctionNames : String{
        case ListCards = "listCards"
        case DeleteCard = "deleteCard"
        case CreateCard = "createCard"
        case CreateCharge = "createCharge"
        case CreateChargeExistingCard = "createChargeExistingCard"
        case CreateCustomer = "createCustomer"
    }
#endif

class Constantes{
    
    private static var queue : dispatch_queue_t?
    
    static let COLOR_NARANJA_NAVBAR:UIColor = UIColor.orangeColor()
    #if DEBUG
    static let STRIPE_PLUBISHABLE_KEY = "pk_test_5A3XM2TUHd6pob50dw7jhxA0"
    #else
    static let STRIPE_PLUBISHABLE_KEY = "pk_live_HoLJQSZCGnDDLDUJ8KAGpvop"
    #endif
    
    /**
     This constants is an array of images that will appear in many background view of the application
     */
    static let animalArrayImages = [UIImage(named: "tigre")!, UIImage(named: "dog")!, UIImage(named: "leopard")!, UIImage(named: "titi")!]
    
    /**
     This function will provide a static queue for all the asyncronus loading that the app needs
     You should not use a default queue as those are shared system resources.
     
     - returns: A concurrent dispatch queue that will be used by the app
     
     */
    class func get_bondzu_queue()-> dispatch_queue_t{
        if queue == nil{
            Constantes.queue = dispatch_queue_create("bondzu.queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INTERACTIVE, -1))
        }
        
        return queue!
    }
}

let LOCALIZED_STRING = "locale"
let privacyURL = NSURL(string: "http://bondzu.com/privacy.html")
let planPurchaseURL = NSURL(string: "https://bondzu.com/purchase.php")

enum TableNames : String{
    case Events_table = "Calendar"
    case VideoCapsule_table = "Video"
    case Animal_table = "AnimalV2"
    case Transactions_table = "Transacciones"
    case Messages_table = "Messages"
    case Reply_table = "Comment"
    case Gallery_table = "Gallery"
    case Products = "Productos"
    case User = "User"
    case Camera = "Camera"
    case UserType = "UserType"
    case StoreProduct = "Store"
    case StoreProductPrice = "StorePrice"
}

enum TableVideoCapsuleNames : String{
    case YoutubeID = "youtube_ids"
    case Title = "titles"
    case Description = "descriptions"
    case AnimalID = "animal_id"
    case Date = "createdAt"
    case UserRequiredType = "videoRequiredPriority"
}


enum TableEventsColumnNames : String{
    case Name = "title"
    case Description = "description"
    case Start_Day = "start_date"
    case End_Day = "end_date"
    case Image_Name = "event_photo"
    case Animal_ID = "id_animal"
}

enum TableAnimalColumnNames : String{
    case Name = "name"
    case Adopters = "adopters"
    case Species = "species"
    case Characteristics = "characteristics"
    case About = "about"
    case Photo = "profilePhoto"
    case Keepers = "keepers"
    case Product = "Productos"
    case ID = "objectId"
    case UserRequiredType = "animalRequiredPriority"
}

enum TableUserColumnNames : String{
    case AdoptedAnimalsRelation = "adoptersRelation"
    case PhotoURL = "photo"
    case PhotoFile = "photoFile"
    case Name = "name"
    case StripeID = "stripeId"
    case UserName = "username"
    case Mail = "email"
    case UserType = "userType"
}

enum TableKeeperColumnNames : String{
    case User = "user"
}

enum TableTransactionColumnNames : String{
    case User = "userid"
    case Price = "precio"
    case Product = "productoid"
    case Description = "descripcion"
    case Transaction = "transaccionid"    
}

enum TableProductColumnNames : String{
    case Name = "nombre"
    case Description = "descripcion"
    case AnimalID = "animal_Id"
    case Picture = "photo"
    case Category = "categoria"
    case Price1 = "precio1"
    case Price2 = "precio2"
    case Price3 = "precio3"
    case Available = "disponible"
    case Information = "info"
    case InformationUsage = "info_ammount"
}

enum TableMessagesColumnNames : String{
    case Date = "createdAt"
    case Message = "message"
    case Animal = "animal_Id"
    case LikesRelation = "likesRelation"
    case Photo = "photo_message"
    case User = "id_user"
}

enum TableReplyColumnNames : String{
    case Message = "message"
    case Date = "createdAt"
    case ParentMessage = "parent"
    case User = "id_user"
}

enum TableGalleryColumnNames : String{
    case Animal = "animal_id"
    case Image = "image"
}

enum TableCameraColumnNames : String{
    case Animal = "animal_Id"
    case Description = "description"
    case AnimalName = "animal_name"
    case Working = "funcionando"
    case PlayBackURL = "url"
    case StatisticTime = "statisticTime"
}

enum TableUserTypeColumnNames : String{
    case Priority = "priority"
    case Purchasable = "sellable"
    case RedChanel = "redColorID"
    case BlueChanel = "blueColorID"
    case GreenChanel = "greenColorID"
    case Cost = "cost"
    case UserTypeName = "name"
}

enum TableStoreProductColumnNames : String{
    case Name = "name"
    case Description = "description"
    case Type = "type"
    case Image = "picture"
    case Purchasable = "sellable"
}

enum TableStorePriceColumnNames : String{
    case Price = "price"
    case Product = "product"
    case Prority = "minPriority"
}

enum Errors : ErrorType{
    case GenericError
}

