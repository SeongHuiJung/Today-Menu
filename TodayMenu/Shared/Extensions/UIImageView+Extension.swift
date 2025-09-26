//
//  UIViewImage+Extension.swift
//  ModuClass
//
//  Created by 정성희 on 9/5/25.
//

import UIKit
import Kingfisher
import Alamofire

extension UIImageView {
    func setDownSamplingImage(url: String?) {
        let processor = DownsamplingImageProcessor(size: self.bounds.size)
        
        if let url = URL(string: url ?? "") {
            self.kf.setImage(with: url, options: [.processor(processor)])
        }
        else {
            self.image = UIImage(systemName: "xmark")
        }
    }
}
