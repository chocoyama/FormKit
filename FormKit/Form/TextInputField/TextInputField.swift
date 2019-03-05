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
    
    private var configuration: Configuration?
    
    public weak var delegate: TextInputFieldDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }

    @discardableResult
    public func configure(with configuration: Configuration) -> Self {
        self.configuration = configuration
        configure(configuration.layout)
        configure(configuration.title)
        configure(configuration.inputField)
        configure(configuration.validation)
        return self
    }
    
    private func configure(_ layout: Configuration.Layout) {
        stackView.axis = layout.axis
        switch layout.axis {
        case .horizontal:
            stackView.alignment = .top
        case .vertical:
            stackView.alignment = .fill
        }

        outsideStackView.spacing = layout.spacing
        stackView.spacing = layout.spacing
        
        marginTopConstraint.constant = layout.margin.top
        marginLeftConstraint.constant = layout.margin.left
        marginRightConstraint.constant = -layout.margin.right
        marginBottomConstraint.constant = -layout.margin.bottom
    }
    
    private func configure(_ title: Configuration.Title) {
        if let titleValue = title.value {
            titleLabel.isHidden = false
            titleLabel.text = titleValue
            titleLabel.font = title.font
            titleLabel.textColor = title.color
        } else {
            titleLabel.isHidden = true
        }
    }
    
    private func configure(_ inputField: Configuration.InputField) {
        placeholderTextView.configure(with: .init(inputField: inputField))
    }
    
    private func configure(_ validation: Configuration.Validation) {
        if let maxInputCount = validation.maxInputCount {
            inputLimitLabel.isHidden = false
            inputLimitLabel.text = "\(maxInputCount)"
        } else {
            inputLimitLabel.isHidden = true
        }
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

private extension PlaceholderTextView.Configuration {
    init(inputField: TextInputField.Configuration.InputField) {
        self.text = inputField.text
        self.placeholder = inputField.placeholder
        self.font = inputField.font
        self.color = inputField.color
        self.border = inputField.border
    }
}
