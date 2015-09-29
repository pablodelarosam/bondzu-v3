//
//  AdoptedAnimalTableViewCell.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/29/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class AdoptedAnimalTableViewCell: UITableViewCell {

    @IBOutlet weak var animalImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var animalDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
