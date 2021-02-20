//
//  ImageView+setImagebyNuke.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/17.
//

import UIKit
import Nuke

extension UIImageView {
    func setImage(with url: URL){
        loadImage(with: url, into: self)
    }
}
