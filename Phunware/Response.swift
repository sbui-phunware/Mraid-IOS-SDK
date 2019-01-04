//
//  Response.swift
//  Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation

/// Types of response status.
public enum ResponseStatus: String {
    /// Success response status.
    case success = "SUCCESS"
    /// No ads status.
    case noAds = "NO_ADS"
}

/// Types of responses you can receive from the API.
public enum Response {
    /// Success response with a `ResponseStatus` and list of `Placement`s.
    case success(ResponseStatus, [Placement])
    /// Bad request with a status code and response body.
    case badRequest(Int?, String?)
    /// The response is not recognized as a valid JSON object.
    case invalidJson(String?)
    /// Request failed with the error.
    case requestError(Error)
}
