//
//  TextInputField.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/02/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol TextInputFieldDelegate: class {
    func textInputField(_ textInputField: TextInputField, didChangeWith text: String?)
    func textInputField(_ textInputField: TextInputField, didEndEditingWith text: String?)
}

public class TextInputField: UIView, XibInitializable {
    
    @IBInspectable var horizontal: Bool = false {
        didSet {
            stackView.axis = horizontal ? .horizontal : .vertical
            switch stackView.axis {
            case .horizontal: stackView.alignment = .top
            case .vertical: stackView.alignment = .fill
            }
        }
    }
    
    @IBInspectable var spacing: CGFloat = 0.0 {
        didSet {
            outsideStackView.spacing = spacing
            stackView.spacing = spacing
        }
    }
    
    @IBInspectable var margin: CGFloat = 0.0 {
        didSet {
            marginTopConstraint.constant = margin
            marginLeftConstraint.constant = margin
            marginRightConstraint.constant = -margin
            marginBottomConstraint.constant = -margin
        }
    }
    
    @IBInspectable var title: String? = nil {
        didSet {
            if let title = title {
                titleLabel.isHidden = false
                titleLabel.text = title
            } else {
                titleLabel.isHidden = true
            }
        }
    }
    
    @IBInspectable var titleFont: UIFont = .systemFont(ofSize: 17) {
        didSet { titleLabel.font = titleFont }
    }
    
    @IBInspectable var titleColor: UIColor = .black {
        didSet { titleLabel.textColor = titleColor }
    }
    
    @IBInspectable var inputFieldText: String = "" {
        didSet { placeholderTextView.setText(inputFieldText) }
    }
    
    @IBInspectable var inputFieldPlaceholder: String = "" {
        didSet { placeholderTextView.setPlaceholder(inputFieldPlaceholder) }
    }
    
    @IBInspectable var inputFieldTextFont: UIFont = .systemFont(ofSize: 17) {
        didSet { placeholderTextView.setFont(inputFieldTextFont) }
    }
    
    @IBInspectable var inputFieldTextColor: UIColor = .black {
        didSet { placeholderTextView.setColor(inputFieldTextColor) }
    }
    
    @IBInspectable var inputFieldBorderColor: UIColor = .clear {
        didSet {
            let border = (color: inputFieldBorderColor, width: inputFieldBorderWidth)
            placeholderTextView.setBorder(border)
        }
    }
    
    @IBInspectable var inputFieldBorderWidth: CGFloat = 0.0 {
        didSet {
            let border = (color: inputFieldBorderColor, width: inputFieldBorderWidth)
            placeholderTextView.setBorder(border)
        }
    }
    
    @IBInspectable var maxInputCount: Int = 0 {
        didSet {
            if maxInputCount == 0 {
                inputLimitLabel.isHidden = true
            } else {
                inputLimitLabel.isHidden = false
                inputLimitLabel.text = "\(maxInputCount)"
            }
        }
    }
    
    @IBOutlet weak var outsideStackView: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderTextView: PlaceholderTextView! {
        didSet {
            placeholderTextView.delegate = self
        }
    }
    @IBOutlet weak var inputLimitLabel: UILabel!
    
    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginBottomConstraint: NSLayoutConstraint!
    
    public weak var delegate: TextInputFieldDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }
}

extension TextInputField: PlaceholderTextViewDelegate {
    public func placeholderTextView(_ placeholderTextView: PlaceholderTextView, didChangeWith text: String?) {
        delegate?.textInputField(self, didChangeWith: text)
    }
    
    public func placeholderTextView(_ placeholderTextView: PlaceholderTextView, didEndEditingWith text: String?) {
        delegate?.textInputField(self, didEndEditingWith: text)
    }
}
