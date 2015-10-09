//
//  Constantes.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 13/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import UIKit

class Constantes
{
    static let COLOR_NARANJA_NAVBAR:UIColor = UIColor.orangeColor()
    static let STRIPE_PLUBISHABLE_KEY = "pk_test_5A3XM2TUHd6pob50dw7jhxA0"
    
}

let LOCALIZED_STRING = "locale"


enum TableNames : String{
    case Events_table = "Calendar"
    case VideoCapsule_table = "Video"
    case Animal_table = "AnimalV2"
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
    
}

enum TableUserColumnNames : String{
    case AdoptedAnimalsRelation = "adoptersRelation"
    case PhotoURL = "photo"
    case PhotoFile = "photoFile"
    case Name = "name"
}

enum TableKeeperColumnNames : String{
    case User = "user"
}