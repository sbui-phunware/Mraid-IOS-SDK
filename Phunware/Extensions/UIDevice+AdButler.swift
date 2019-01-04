//
//  UIDevice+Phunware.swift
//  Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import UIKit

extension UIDevice {
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { carryOver, e in
            guard let value = e.value as? Int8, value != 0 else {
                return carryOver
            }
            return carryOver + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    static var osVersion: String {
        return [UIDevice.current.systemName, UIDevice.current.systemVersion].joined(separator: " ")
    }
}
