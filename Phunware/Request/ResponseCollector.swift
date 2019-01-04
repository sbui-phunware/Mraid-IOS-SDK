//
//  ResponseCollector.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation

protocol ResponseCollector {
    var responses: [Response] { get }
    var complete: (Response) -> Void { get }
}
