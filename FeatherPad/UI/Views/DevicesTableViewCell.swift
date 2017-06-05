//
//  DevicesTableViewCell.swift
//  FeatherPad
//
//  Created by Nick McDonald on 6/4/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class DevicesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceIsSelectedImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    var deviceData: FeatherPadDevice? {
        didSet {
            self.deviceNameLabel.text = deviceData?.name ?? "Vicky"
            if deviceData != FeatherPadDevice.currentSelectedDevice {
                self.deviceIsSelectedImageView.image = nil
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.deviceIsSelectedImageView.image = #imageLiteral(resourceName: "green check")
    }

}
