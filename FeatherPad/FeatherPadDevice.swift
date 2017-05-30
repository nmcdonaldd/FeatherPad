//
//  FeatherPadDevice.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/29/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class FeatherPadDevice: NSObject {
    
    var id: String?
    
    init(withDeviceID deviceID: String) {
        self.id = deviceID
    }
    
    convenience init(inputDict: [String : Any?]) {
        self.init(withDeviceID: inputDict["device_id"] as! String)
    }
    
    class func devicesFromIDs(_ ids: [String]) -> [FeatherPadDevice] {
        var toReturn = [FeatherPadDevice]()
        for id in ids {
            toReturn.append(FeatherPadDevice(withDeviceID: id))
        }
        return toReturn
    }
}
