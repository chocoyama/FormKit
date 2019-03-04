//
//  TextInputFieldConfiguration.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

extension TextInputField {
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
}
