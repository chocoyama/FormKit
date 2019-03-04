//
//  TextInputField.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/02/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public class TextInputField: UIView, XibInitializable {
    
    public struct Configuration {
        public struct Layout {
            public var axis: NSLayoutConstraint.Axis = .vertical
            public var spacing: CGFloat = 0
            public var margin: UIEdgeInsets = .zero
            
            public init() {}
        }
        
        public struct Title {
            public var value: String? = "Title"
            public var font: UIFont = .systemFont(ofSize: 17)
            public var color: UIColor = .black
            
            public init() {}
        }
        
        public struct InputField {
            public var text: String = ""
            public var placeholder: String = "Placeholder"
            public var font: UIFont = .systemFont(ofSize: 17)
            public var color: UIColor = .black
            public var border: (color: UIColor, width: CGFloat)?
            
            public init() {}
        }
        
        public struct Validation {
            public enum Timing {
                case didChange
                case didEndEditing
            }
            
            public enum ValidateResult {
                case valid
                case invalid(message: String)
            }
            
            public typealias InputValue = String
            
            public var check: ((InputValue) -> ValidateResult)?
            public var timing: Timing = .didEndEditing
            public var maxInputCount: Int? = 100
            
            public init() {}
        }
        
        public var layout = Layout()
        public var title = Title()
        public var inputField = InputField()
        public var validation = Validation()
        
        public init() {}
    }
    
    @IBOutlet weak var outsideStackView: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderTextView: PlaceholderTextView!
    @IBOutlet weak var inputLimitLabel: UILabel!
    
    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var marginBottomConstraint: NSLayoutConstraint!
    
    private var configuration: Configuration?
    
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

extension PlaceholderTextView.Configuration {
    init(inputField: TextInputField.Configuration.InputField) {
        self.text = inputField.text
        self.placeholder = inputField.placeholder
        self.font = inputField.font
        self.color = inputField.color
        self.border = inputField.border
    }
}
