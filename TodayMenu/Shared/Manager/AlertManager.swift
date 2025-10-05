//
//  AlertManager.swift
//  ModuClass
//
//  Created by 정성희 on 9/4/25.
//

import UIKit

class AlertManager {
    static let shared = AlertManager()
    private init() {}
    
    func makeInfoAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okButton)
        return alert
    }
    
    func makeInfoAlertWithPop(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alert
    }
}
