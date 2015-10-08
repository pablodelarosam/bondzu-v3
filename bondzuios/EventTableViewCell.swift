//
//  EventTableViewCell.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/6/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var calendarInputAccesory: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var indexPath : NSIndexPath?
    var gestureRecognizer : UITapGestureRecognizer?
    
    var delegate : EventTableViewCellDelegate?
    
    func load(title : String, date : NSDate, description : String, eventImage : UIImage, path : NSIndexPath){
        if let gr = gestureRecognizer{
            calendarInputAccesory.removeGestureRecognizer(gr)
        }
        
        indexPath = path
        gestureRecognizer = UITapGestureRecognizer(target: self, action: "tapedImageGestureRecognizer")
        calendarInputAccesory.userInteractionEnabled = true
        calendarInputAccesory.addGestureRecognizer(gestureRecognizer!)
        
        self.eventImage.image = eventImage
        eventTitle.text = title
        
        let formater = NSDateFormatter()
        formater.dateStyle = NSDateFormatterStyle.ShortStyle
        formater.timeStyle = NSDateFormatterStyle.NoStyle
        dateLabel.text = formater.stringFromDate(date)
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
    func inputAccesoryPressedInCellWithIndexPath(indexPath : NSIndexPath)
}