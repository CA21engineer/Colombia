//
//  UICollectionViewCell + Nib + Identifer.swift
//  Colombia
//
//  Created by 化田晃平 on R 3/02/17.
//
import UIKit

extension UICollectionViewCell {
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
    }
}
