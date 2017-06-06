//
//  TemperatureHumidityLabel.swift
//  FeatherPad
//
//  Created by Nick McDonald on 6/5/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class TemperatureHumidityLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.borderColor = UIColor(red: 67/255, green: 160/255, blue: 71/255, alpha: 1.0).cgColor
        self.layer.borderWidth = 3.0
        self.clipsToBounds = false
    }

}
