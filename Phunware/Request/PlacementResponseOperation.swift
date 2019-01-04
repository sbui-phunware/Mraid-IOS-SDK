//
//  PlacementResponseOperation.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation

class PlacementResponseOperation: AsynchronousOperation {
    let _responseCollector: ResponseCollector
    
    init(responseCollector: ResponseCollector) {
        _responseCollector = responseCollector
    }
    
    override func main() {
        defer {
            finish()
        }
        
        let responses = _responseCollector.responses
        var placements = [Placement]()
        for response in responses {
            if case let .success(_, eachPlacements) = response {
                // we aggregate all successful responses
                placements.append(contentsOf: eachPlacements)
            } else {
                // for unsuccessful requests, we just return the first failure
                _responseCollector.complete(response)
                return
            }
        }
        let status: ResponseStatus = placements.isEmpty ? .noAds : .success
        _responseCollector.complete(.success(status, placements))
    }
}
