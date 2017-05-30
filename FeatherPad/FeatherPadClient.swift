//
//  FeatherPadClient.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/29/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import UIKit

private enum HTTPType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
}

enum FeatherPadClientError: Error {
    case badURL
    case invalidResponse(String)
    case dataSerializationError
}

class FeatherPadClient: NSObject {
    
    private static let baseAPIURL = "https://featherpad.herokuapp.com/api"
    private static let loginEndpoint = "/login_mobile/create/"  // Append Username and password: <string:username>/<string:password>
    
    // TODO: - Singleton FeatherPadAPIClient? Is this necessary? Probably not --> useful if doing an OAuth approach.
    
    
    // MARK: - Methods.
    
    func login(withUsername username: String, password: String, success: @escaping (User)->(), failure: @escaping (Error?)->()) {
        self.api(endpoint: FeatherPadClient.loginEndpoint, type: .post, success: { (responseData: Data?) in
            // Success block.
            // This block should handle creating the device ids and adding them to a new user.
            guard responseData != nil else {
                // Let's hope the response is not nil.
                failure(FeatherPadClientError.invalidResponse("Server returned no data."))
                return
            }
            
            // Cast the return value as an array of [String: Any?] array.
            if let dictionaries = try! JSONSerialization.jsonObject(with: responseData!, options: []) as? [[String: Any?]] {
                var devices = [FeatherPadDevice]()
                for dictionary in dictionaries {
                    guard let deviceID = dictionary["device_id"] as? String else {
                        // For now, just continue on to next device if there is no device_id for some reason.
                        continue
                    }
                    let device = FeatherPadDevice(withDeviceID: deviceID)
                    devices.append(device)
                }
                let loggedInUser = User(withDevices: devices)
                success(loggedInUser)
            } else {
                // What to do if we cannot serialize it? Call failure on error?
                failure(FeatherPadClientError.dataSerializationError)
            }
        }) { (error: Error?) in
            // Failure block.
            failure(error)
        }
    }
    
    fileprivate func api(endpoint: String, type: HTTPType, success: @escaping (Data?)->(), failure: @escaping (Error?)->()) {
        guard let requestURL = URL(string: endpoint, relativeTo: URL(string: FeatherPadClient.baseAPIURL)) else {
            failure(FeatherPadClientError.badURL)   // Bad url, couldn't make URL object from the string.
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
