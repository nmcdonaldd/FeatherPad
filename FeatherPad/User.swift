//
//  User.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/29/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

class User: NSObject {
    
    private static var defaultUserDevicesIDsIdentifier = "default_device_ids"
    var associatedDevices: [FeatherPadDevice]?
    private static var _currentUser: User?
    static var currentUser: User? {
        get {
            if _currentUser == nil {
                // Check if there are any stored stuff. Can simply use user defaults.
                let defaults = UserDefaults.standard
                guard let deviceIDs = defaults.stringArray(forKey: User.defaultUserDevicesIDsIdentifier) else {
                    // This means there are no defaults for the user. --> No logged-in user.
                    return nil
                }
                let devices = FeatherPadDevice.devicesFromIDs(deviceIDs)
                _currentUser = User(withDevices: devices)
                return _currentUser
            } else {
                return _currentUser
            }
        }
        
        set {
            var deviceIDs = [String]()
            for device in (currentUser?.associatedDevices)! {
                deviceIDs.append(device.id!)
            }
            let defaults = UserDefaults.standard
            defaults.set(deviceIDs, forKey: User.defaultUserDevicesIDsIdentifier)
            defaults.synchronize()
        }
    }
    
    init(withDevices featherPadDevices: [FeatherPadDevice]) {
        self.associatedDevices = featherPadDevices
    }

}
