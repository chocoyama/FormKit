//
//  CustomEdgeInsetsLabel.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/02/28.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

@IBDesignable
class CustomEdgeInsetsLabel: UILabel {
    
    @IBInspectable open var topInset: CGFloat = 1.0
    @IBInspectable open var bottomInset: CGFloat = 1.0
    @IBInspectable open var leftInset: CGFloat = 2.0
    @IBInspectable open var rightInset: CGFloat = 2.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        return super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        let width = (size.width > 0) ? size.width + leftInset + rightInset : size.width
        let height = (size.height > 0) ? size.height + topInset + bottomInset * 2 : size.height
        
        return CGSize(width: width, height: height)
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    var customizedFrame: CGRect {
        var newFrame = self.frame
        newFrame.size = self.intrinsicContentSize
        return newFrame.offsetBy(dx: 0, dy: -(topInset + bottomInset))
    }
}
