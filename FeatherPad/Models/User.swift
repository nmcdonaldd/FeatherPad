//
//  User.swift
//
//  Copyright © 2017 Team Exponent (https://featherpad.herokuapp.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

enum UserError: Error {
    case BadUsernameOrPassword(String)
}

enum UserNotificationCenterOps: String {
    case userDidLogout = "UserDidLogOut"
    
    var notification: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

class User {
    
    private static var defaultUserDevicesIDsIdentifier = "default_device_ids"
    var associatedDevices: [FeatherPadDevice]?
    private static var _currentUser: User?
    static var currentUser: User? {
        get {
            if _currentUser == nil {
                // Check if there are any stored stuff. Can simply use user defaults.
                let defaults = UserDefaults.standard
                guard let deviceDatas = defaults.value(forKey: User.defaultUserDevicesIDsIdentifier) as? [Data] else {
                    // This means there are no defaults for the user. --> No logged-in user.
                    return nil
                }
                // Now have array of data: [Data].
                var devices = [FeatherPadDevice]()
                for deviceData in deviceDatas {
                    let deviceAsDict = try! JSONSerialization.jsonObject(with: deviceData, options: .allowFragments) as! [String: Any?]
                    let device = FeatherPadDevice(inputDict: deviceAsDict)
                    devices.append(device)
                }
                _currentUser = User(withDevices: devices)
                return _currentUser
            } else {
                return _currentUser
            }
        }
        
        set {
            _currentUser = newValue
            let defaults = UserDefaults.standard
            if let currentUser = newValue {
                var deviceDatas = [Data]()
                for device in (currentUser.associatedDevices)! {
                    let dict = device.asDict
                    let data = try! JSONSerialization.data(withJSONObject: dict as Any, options: [])
                    deviceDatas.append(data)
                }
                defaults.set(deviceDatas, forKey: User.defaultUserDevicesIDsIdentifier)
            }
            else {
                defaults.set(nil, forKey: User.defaultUserDevicesIDsIdentifier)
            }
            defaults.synchronize()
        }
    }
    
    /// This method will post the logout notification to NotificationCenter.
    class func logoutCurrentUser(completion: (()->Swift.Void)?) {
        User.currentUser = nil
        NotificationCenter.default.post(name: UserNotificationCenterOps.userDidLogout.notification, object: nil)
        completion?()
    }
    
    init(withDevices featherPadDevices: [FeatherPadDevice]) {
        self.associatedDevices = featherPadDevices
    }
    
    class func loginUser(withUsername username: String?, password: String?, success: @escaping ()->(), failure: @escaping (Error?)->()) {
        guard username != nil, password != nil else {
            failure(UserError.BadUsernameOrPassword("Username or password is nil."))
            return
        }
        let fpClient = FeatherPadClient()
        fpClient.login(withUsername: username!, password: password!, success: { (loggedInUser: User) in
            // Set the current user.
            User.currentUser = loggedInUser
            success()
        }) { (error: Error?) in
            failure(error)
        }
    }
}
