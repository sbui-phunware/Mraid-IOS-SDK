//
//   PhunwareCustomExtras.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import Foundation

public class PWCustomExtras {
    private var Label : String
    public var Extras : [AnyHashable: Any]
    
    public init(label: String, values: [AnyHashable: Any] = [ : ]){
        self.Label = label
        Extras = [:]
    }
    
    public func GetLabel() -> String {
        return self.Label
    }
}
