//
//  IdentifierProtocol.swift
//  ModuClass
//
//  Created by 정성희 on 9/4/25.
//

import UIKit

protocol IdentifierProtocol {
    static var identifier: String { get }
}

extension UIViewController: IdentifierProtocol{
    static var identifier : String {
        return String(describing: self)
    }
}

extension UITableViewCell: IdentifierProtocol {
    static var identifier : String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: IdentifierProtocol {
    static var identifier : String {
        return String(describing: self)
    }
}

