//
//  FeatherPadDevice.swift
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

enum DeviceNotificationCenterOps: String {
    case currentlySelectedDeviceDidChange = "SelectedDeviceChanged"
    
    var notification: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

enum FeatherPadDeviceError: LocalizedError {
    case userAlreadyOwnsDevice
    
    var errorDescription: String? {
        return "You have already added this device to your account."
    }
}

//extension FeatherPadDeviceError: LocalizedError {
//    var errorDescription: String {
//        return "You have already added this device to your account."
//    }
//}

class FeatherPadDevice: Hashable {
    
    /// Name of the device.
    var name: String?
    
    /// ID of the device.
    var id: String?
    
    /// List of Temperature/Humidity reading objects for this device.
    var tempHumReadings: [TempHumReading]?
    
    /// List of ForcePadAlerts objects for this device.
    var forcePadAlerts: [ForcePadAlert]?
    
    /// Hashable conformance.
    var hashValue: Int {
        return Int(self.id!)!
    }
    
    /// Dictionary of device.
    var asDict: [String: Any?]?
    
    static private var _currentDevice: FeatherPadDevice?
    
    /// Current device.
    static var currentSelectedDevice: FeatherPadDevice? {
        get {
            if _currentDevice == nil {
                // Grab from defaults.
                _currentDevice = User.currentUser?.associatedDevices?[0]
            }
            return _currentDevice
        }
        
        set {
            _currentDevice = newValue
            NotificationCenter.default.post(name: DeviceNotificationCenterOps.currentlySelectedDeviceDidChange.notification, object: newValue)
        }
    }
    
    init(inputDict: [String : Any?]) {
        self.asDict = inputDict
        self.id = inputDict["device_id"] as? String
        self.name = inputDict["device_name"] as? String ?? self.id
    }
    
    /// Method to update this devices temperature humidity readings as well as ForcePadAlerts. NOTE: the success or failure block might not be called on the Main queue.
    func updateDeviceReadings(success: @escaping ([TempHumReading]?, [ForcePadAlert]?)->(), failure: @escaping (Error?)->()) {
        let fpClient = FeatherPadClient()
        let group = DispatchGroup()
        
        // Enter the group for getting temp/hum alerts.
        group.enter()
        fpClient.getTempHumReadingsForDeviceWithID(self.id!, success: { (tempHumReadings: [TempHumReading]?) in
            // Success.
            self.tempHumReadings = tempHumReadings
            group.leave()
        }, failure: { (error: Error?) in
            // Failure.
            failure(error)
            group.leave()
        })
        group.enter()
        fpClient.getForcePadAlertsForDeviceWithID(self.id!, success: { (alerts: [ForcePadAlert]?) in
            self.forcePadAlerts = alerts
            group.leave()
        }) { (error: Error?) in
            failure(error)
            group.leave()
        }
        group.notify(queue: .main) {
            success(self.tempHumReadings, self.forcePadAlerts)
        }
    }
    
    class func DevicesFromDict(_ devices: [[String: Any?]]) -> [FeatherPadDevice] {
        var output = [FeatherPadDevice]()
        for device in devices {
            output.append(FeatherPadDevice(inputDict: device))
        }
        return output
    }
    
    /// Hashable conforms to equatable, so need to implement equatable conformance.
    static func ==(lhs: FeatherPadDevice, rhs: FeatherPadDevice) -> Bool {
        return lhs.id == rhs.id
    }
}
