//
//  LoginButton.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/29/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 2.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = appPrimaryColor.cgColor
        self.clipsToBounds = false
    }
}
