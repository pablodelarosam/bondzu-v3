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


class Constantes
{
    static let COLOR_NARANJA_NAVBAR:UIColor = UIColor.orangeColor()
    #if DEBUG
    static let STRIPE_PLUBISHABLE_KEY = "pk_test_5A3XM2TUHd6pob50dw7jhxA0"
    #else
    static let STRIPE_PLUBISHABLE_KEY = "pk_live_HoLJQSZCGnDDLDUJ8KAGpvop"
    #endif
}

let LOCALIZED_STRING = "locale"
let privacyURL = NSURL(string: "http://bondzu.com/privacy.html")


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
}

enum TableVideoCapsuleNames : String{
    case YoutubeID = "youtube_ids"
    case Title = "titles"
    case Description = "descriptions"
    case AnimalID = "animal_id"
    case Date = "createdAt"
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
}


enum Errors : ErrorType{
    case GenericError
}