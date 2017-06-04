//
//  TempHumReading.swift
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

import Foundation
import SwiftDate

class TempHumReading {
    
    private static let topTemperatureValue = 28
    
    /// This is the temperature value of the reading in Celsius.
    var temperatureValue: Int! {
        if !Settings.usesCelsius {
            // This means we are using Fahrenheit.
            return Int((Double(self.tempInCelsius) * (9.0/5.0) + 32))
        }
        return self.tempInCelsius
    }
    
    var isAboveThreshold: Bool!
    
    /// This is the formatted temperature value represented in a String. I.e. 70*F
    var formattedTemperature: String! {
        let celciusSetting: Bool = Settings.usesCelsius
        let unitString = celciusSetting ? "C" : "F"
        return "\(self.temperatureValue!)° \(unitString)"
    }
    
    private var tempInCelsius: Int!
    
    /// This is the temperature value of the reading in fahrenheit.
    var temperatureValueFahrenheit: Int!
    
    /// This is the humidity value of the reading as a percentage.
    var humidityValue: Int!
    
    /// This is the ID of the temperature/humidity reading.
    var id: Int!
    
    /// Timestamp of the temperature/humidity reading.
    var timestamp: Date!
    
    /// Formatted (relative) date.
    // This is a computed property since asking for the reading object's realtive time can happen at a later time.
    var relativeTimeStamp: String! {
        let din: DateInRegion? = DateInRegion(absoluteDate: self.timestamp)
        let (colloquial, _): (String, String?) = try! din!.colloquialSinceNow()
        
        return colloquial
    }
    
    init(withDictionary inputDict: [String: Any?]) {
        self.tempInCelsius = inputDict["temperature"] as! Int
        self.humidityValue = inputDict["humidity"] as! Int
        self.id = inputDict["id"] as! Int
        self.isAboveThreshold = self.tempInCelsius > TempHumReading.topTemperatureValue
        
        // Format the date input to a Date object using DateFormatter.
        // Example format of the timestamp is "Sun, 07 May 2017 23:14:50 GMT".
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMMM yyyy HH:mm:ss ZZZZ"
        self.timestamp = df.date(from: (inputDict["timestamp"] as? String)!)
    }
    
    class func TempHumReadingsFromDict(inputDict: [[String: Any?]]) -> [TempHumReading] {
        var output = [TempHumReading]()
        for reading in inputDict {
            output.append(TempHumReading(withDictionary: reading))
        }
        return output
    }
}
