//
//  FeatherPadClientError.swift
//  FeatherPad
//
//  Created by Nick McDonald on 6/10/17.
//  Copyright © 2017 nickdonald. All rights reserved.
//

import Foundation

enum FeatherPadClientError: Error {
    case BadURL
    case InvalidResponse(String)
    case DataSerializationError
}

extension FeatherPadClientError: LocalizedError {
    public var errorDescription: String? {
        return "The request could not be handled at this time, please try again."
    }
}
