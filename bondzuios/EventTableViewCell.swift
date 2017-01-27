//
//  EventTableViewCell.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/6/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var calendarInputAccesory: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var indexPath : IndexPath?
    var gestureRecognizer : UITapGestureRecognizer?
    
    var delegate : EventTableViewCellDelegate?
    
    func load(_ title : String, date : Date, description : String, eventImage : UIImage, path : IndexPath){
        if let gr = gestureRecognizer{
            calendarInputAccesory.removeGestureRecognizer(gr)
        }
        
        indexPath = path
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventTableViewCell.tapedImageGestureRecognizer))
        calendarInputAccesory.isUserInteractionEnabled = true
        calendarInputAccesory.addGestureRecognizer(gestureRecognizer!)
        
        self.eventImage.image = eventImage
        eventTitle.text = title
        
        let formater = DateFormatter()
        formater.dateStyle = DateFormatter.Style.short
        formater.timeStyle = DateFormatter.Style.none
        dateLabel.text = formater.string(from: date)
        descriptionLabel.text = description

        
        descriptionLabel.adjustsFontSizeToFitWidth = true
    }
    
    func tapedImageGestureRecognizer(){
        delegate?.inputAccesoryPressedInCellWithIndexPath(indexPath!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Imagenes.redondeaVista(eventImage, radio: eventImage.bounds.height/2)
    }
    
    
}

protocol EventTableViewCellDelegate{
    func inputAccesoryPressedInCellWithIndexPath(_ indexPath : IndexPath)
}
