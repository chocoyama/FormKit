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
        layer.shadowOffset = offsetSize
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        return self
    }
}
