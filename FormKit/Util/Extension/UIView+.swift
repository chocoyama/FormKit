//
//  UIView+.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func overlay(on view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension UIView {
    @discardableResult
    func rounded(masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = bounds.width / 2.0
        layer.masksToBounds = masksToBounds
        return self
    }
    
    @discardableResult
    func rounded(cornerRadius: CGFloat,
                 cornerMasks: CACornerMask = [],
                 masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = masksToBounds
        
        if !cornerMasks.isEmpty {
            layer.maskedCorners = cornerMasks
        }
        
        return self
    }
    
    @discardableResult
    func drawBorder(width: CGFloat, color: UIColor) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func addDropShadow(offsetSize: CGSize,
                       opacity: Float,
                       radius: CGFloat,
                       color: UIColor) -> Self {
        layer.masksToBounds = false
        layer.shadowOffset = offsetSize
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        return self
    }
}
