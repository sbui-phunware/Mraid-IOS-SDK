//
//  ABImageView.swift
//   Phunware
//

//  Copyright © 2018 Phunware, Inc. All rights reserved.
//

import UIKit

public class PWImageView: UIImageView {
    var placement: Placement?
    
    func setupGestures() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func tap() {
        if let urlString = placement?.redirectUrl, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
