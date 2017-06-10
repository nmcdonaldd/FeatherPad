//
//  FeatherPadClient.swift
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

private enum HTTPType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class FeatherPadClient {
    
    private static let baseAPIURL = URL(string: "https://featherpad.herokuapp.com/api/")!
    private static let loginEndpoint = "login_mobile/create"    // Append Username and password: <string:username>/<string:password>
    private static let readTempHumEndpoint = "temp_hum"         // Append the device id: "1234"
    private static let readForcePadAlertsEndpoint = "alerts"
    private static let addDeviceToAccountEndpiont = "device/create"
    
    /// Login method that makes an HTTP Request to log the user in.
    func login(withUsername username: String, password: String, success: @escaping (User)->(), failure: @escaping (Error?)->()) {
        self.api(endpoint: FeatherPadClient.loginEndpoint + "/\(username)/\(password)", type: .post, success: { (response: Data?) in
            // This block should handle creating the device ids and adding them to a new user.
            guard response != nil else {
                // Let's hope the response is not nil.
                failure(FeatherPadClientError.InvalidResponse("Server returned nil data."))
                return
            }
            
            // Cast the return value as an array of [String: Any?].
            if let dictionaries = try? JSONSerialization.jsonObject(with: response!, options: []) as? [[String: Any?]] {
                let devices = FeatherPadDevice.DevicesFromDict(dictionaries!)
                let loggedInUser = User(withDevices: devices)
                
                // Return the user that we just logged in.
                success(loggedInUser)
                return
            } else {
                // What to do if we cannot serialize the data? Call failure on error!
                failure(FeatherPadClientError.DataSerializationError)
            }
        }) { (error: Error?) in
            // Failure block. Just pass along the error to the failure block given.
            failure(error)
        }
    }
    
    /// Method to get the data of a device.
    func addDeviceToUserAccount(deviceID: String, deviceName: String, user: User, success: @escaping (FeatherPadDevice?)->(), failure: @escaping (Error?)->()) {
        self.api(endpoint: FeatherPadClient.addDeviceToAccountEndpiont + "/\(deviceID)/12/\(deviceName)", type: .post, success: { (response: Data?) in
            // Success block should handle creating the device object and returning it.
            guard response != nil else {
                failure(FeatherPadClientError.InvalidResponse("Server returned nil data"))
                return
            }
            
            // Case the return value as an array of [String: Any?]
            if let dictionary = try? JSONSerialization.jsonObject(with: response!, options: .allowFragments) as? [String: Any?] {
                let newDevice = FeatherPadDevice(inputDict: dictionary!)
                success(newDevice)
            }
        }) { (error: Error?) in
            //
            failure(error)
            return
        }
    }
    
    
    /// Method to get the data of temperature_humidity readings from the API.
    func getTempHumReadingsForDeviceWithID(_ id: String, success: @escaping ([TempHumReading]?)->(), failure: @escaping (Error?)->()) {
        self.api(endpoint: FeatherPadClient.readTempHumEndpoint + "/\(id)", type: .get, success: { (response: Data?) in
            // This block should handle creating the temperature and humidity reading objects and passing them off ot the success.
            guard response != nil else {
                failure(FeatherPadClientError.InvalidResponse("Server returned nil data"))
                return
            }
            
            // Cast the return value as an array of [String: Any?].
            if let dictionaries = try? JSONSerialization.jsonObject(with: response!, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any?]] {
                let readings = TempHumReading.TempHumReadingsFromDict(inputDict: dictionaries!)
                // Run the success block with the new readings we just created.
                success(readings)
                return
            } else {
                failure(FeatherPadClientError.DataSerializationError)
                return
            }
        }) { (error: Error?) in
            // Failure block. Just pass along the error to the failure block given.
            failure(error)
            return
        }
    }
    
    /// Method to get the data of ForcePadAlert readigns from the API.
    func getForcePadAlertsForDeviceWithID(_ id: String, success: @escaping ([ForcePadAlert]?)->(), failure: @escaping (Error?)->()) {
        self.api(endpoint: FeatherPadClient.readForcePadAlertsEndpoint, type: .get, success: { (response: Data?) in
            // This block should handle creating the alert objects and passing them off to the success.
            guard response != nil else {
                failure(FeatherPadClientError.InvalidResponse("Server returned nil data"))
                return
            }
            
            // Cast the return value as an array of [String: Any?].
            if let dictionaries = try? JSONSerialization.jsonObject(with: response!, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any?]] {
                let alerts = ForcePadAlert.AlertsFromDictionary(inputDict: dictionaries!)
                // Run the success block with the new alerts.
                success(alerts)
                return
            } else {
                failure(FeatherPadClientError.DataSerializationError)
                return
            }
        }) { (error: Error?) in
            // Failure.
        }
    }
    
    /// General API function to make API calls.
    private func api(endpoint: String, type: HTTPType, success: @escaping (Data?)->(), failure: @escaping (Error?)->()) {
        guard let requestURL = URL(string: endpoint, relativeTo: FeatherPadClient.baseAPIURL) else {
            failure(FeatherPadClientError.BadURL)   // Bad url, couldn't make URL object from the string.
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = type.rawValue
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.current)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                failure(error)
                return
            }
            success(data)
        })
        task.resume()
    }
}
