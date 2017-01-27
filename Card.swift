//
//  Card.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 08/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import Foundation

class Card
{
    var number: String;
    var monthExp: String;
    var yearExp: String;
    var id: String;
    var brand: String;
    
    @available(*,deprecated: 9.0, message: "Please use new param constructor")
    init(){
        number = ""
        monthExp = ""
        yearExp = ""
        id = ""
        brand = ""
    }
    
    init(number : String, monthExp : String, yearExp : String, id : String, brand : String){
        self.number = number
        self.monthExp = monthExp
        self.yearExp = yearExp
        self.id = id
        self.brand = brand
    }
}
