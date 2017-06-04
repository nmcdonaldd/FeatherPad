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

class TempHumReading {
    
    /// This is the temperature value of the reading in Celsius.
    var temperatureValue: Int!
    
    /// This is the humidity value of the reading as a percentage.
    var humidity: Int!
    
    /// This is the ID of the temperature/humidity reading.
    var id: Int!
    
    /// Timestamp of the temperature/humidity reading.
    var timestamp: Date!
    
    init(withDictionary inputDict: [String: Any?]) {
        self.temperatureValue = inputDict["temperature"] as! Int
        self.humidity = inputDict["humidity"] as! Int
        self.id = inputDict["id"] as! Int
        
        // Format the date input to a Date object using DateFormatter.
        // Example format of the timestamp is "Sun, 07 May 2017 23:14:50 GMT".
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMMM yyyy HH:mm:ss ZZZZ"
        self.timestamp = df.date(from: inputDict["timestmap"] as! String)
    }
    
    class func TempHumReadingsFromDict(inputDict: [[String: Any?]]) -> [TempHumReading] {
        var output = [TempHumReading]()
        for reading in inputDict {
            output.append(TempHumReading(withDictionary: reading))
        }
        return output
    }
}
