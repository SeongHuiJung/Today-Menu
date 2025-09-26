//
//  UIView+Extension.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

extension UIView {
    func setCorner(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
