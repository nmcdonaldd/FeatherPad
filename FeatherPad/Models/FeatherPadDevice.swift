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

class FeatherPadDevice {
    
    /// ID of the device.
    var id: String?
    
    /// List of Temperature/Humidity reading objects for this device.
    var tempHumReadings: [TempHumReading]?
    
    /// List of ForcePadAlerts objects for this device.
    var forcePadAlerts: [ForcePadAlert]?
    
    init(withDeviceID deviceID: String) {
        self.id = deviceID
    }
    
    convenience init(inputDict: [String : Any?]) {
        self.init(withDeviceID: inputDict["device_id"] as! String)
    }
    
    /// Method to update this devices temperature humidity readings as well as ForcePadAlerts. NOTE: the success or failure block might not be called on the Main queue.
    func updateDeviceReadings(success: @escaping ([TempHumReading]?, [ForcePadAlert]?)->(), failure: @escaping (Error?)->()) {
        let fpClient = FeatherPadClient()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.exponent.fpClientQueue", attributes: .concurrent)
        var returnedTempHumReadings: [TempHumReading]?
        //var returnedForcePadAlerts: [ForcePadAlert]?
        queue.async {
            // Enter the group for getting temp/hum alerts.
            group.enter()
            fpClient.getTempHumReadingsForDeviceWithID(self.id!, success: { (tempHumReadings: [TempHumReading]?) in
                // Success.
                self.tempHumReadings = tempHumReadings
                returnedTempHumReadings = tempHumReadings
            }, failure: { (error: Error?) in
                // Failure.
                failure(error)
            })
            group.leave()
        }
//        queue.async {
//            // Enter the group for getting ForcePad alerts.
//            group.enter()
//            
//            
//            group.leave()
//        }
        group.notify(queue: queue) {
            // TODO: - Remove the nil once the force pad alerts have updated.
            success(returnedTempHumReadings, nil)
        }
    }
    
    class func DevicesFromIDs(_ ids: [String]) -> [FeatherPadDevice] {
        var toReturn = [FeatherPadDevice]()
        for id in ids {
            toReturn.append(FeatherPadDevice(withDeviceID: id))
        }
        return toReturn
    }
    
    class func DevicesFromDict(_ devices: [[String: Any?]]) -> [FeatherPadDevice] {
        var output = [FeatherPadDevice]()
        for device in devices {
            output.append(FeatherPadDevice(inputDict: device))
        }
        return output
    }
}
