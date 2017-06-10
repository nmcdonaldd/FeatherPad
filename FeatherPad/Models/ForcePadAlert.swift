//
//  ForcePadAlert.swift
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
import SwiftDate

enum SensorLocation {
    case left
    case middle
    case right
    case noAlert
}

class ForcePadAlert {
    
    /// ID of the alert.
    var id: Int?
    
    /// Timestamp of the alert.
    var timestamp: Date!
    
    /// Which sensor triggered the alert.
    var alertingSensor: SensorLocation = .noAlert
    
    /// Formatted (relative) date.
    // This is a computed property since asking for the reading object's realtive time can happen at a later time.
    var relativeTimeStamp: String! {
        let din: DateInRegion? = DateInRegion(absoluteDate: self.timestamp)
            return din!.string(dateStyle: .short, timeStyle: .short)
    }
    
    init(withDictionary inputDict: [String: Any?]) {
        self.id = inputDict["id"] as? Int
        
        let locationOfAlert = inputDict["sensor_id"] as! String
        
        switch locationOfAlert{
        case "RIGHT":
            self.alertingSensor = .right
        case "MIDDLE":
            self.alertingSensor = .middle
        case "LEFT":
            self.alertingSensor = .right
        case "NONE":
            self.alertingSensor = .middle
        default:
            print("THIS IS EMBARRASSING, THIS SHOULD BE PRINTED.")
        }
        
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMMM yyyy HH:mm:ss ZZZZ"
        self.timestamp = df.date(from: (inputDict["timestamp"] as? String)!)
    }
    
    /// Helper function to create an array of alert objects from array of input dictionaries.
    class func AlertsFromDictionary(inputDict: [[String: Any?]]) -> [ForcePadAlert] {
        var output = [ForcePadAlert]()
        for reading in inputDict {
            output.append(ForcePadAlert(withDictionary: reading))
        }
        return output
    }

}
