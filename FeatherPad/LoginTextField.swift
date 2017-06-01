//
//  LoginTextField.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/31/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
}
