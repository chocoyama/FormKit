//
//  PlaceholderTextView.swift
//  Vote
//
//  Created by Takuya Yokoyama on 2018/04/29.
//  Copyright © 2018年 Takuya Yokoyama. All rights reserved.
//

import UIKit

public protocol PlaceholderTextViewDelegate: class {
    func placeholderTextView(_ placeholderTextView: PlaceholderTextView, didChangeWith text: String?)
    func placeholderTextView(_ placeholderTextView: PlaceholderTextView, didEndEditingWith text: String?)
}

public class PlaceholderTextView: UIView, XibInitializable {

    public struct Configuration {
        public typealias Border = (color: UIColor, width: CGFloat)
        
        public var text: String?
        public var color: UIColor?
        public var font: UIFont?
        public var placeholder: String?
        public var border: Border?
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    @IBOutlet weak var placeholderLabel: UILabel!
    
    public weak var delegate: PlaceholderTextViewDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }
    
    public func configure(with configuration: Configuration) {
        setText(configuration.text ?? "")
        
        if let color = configuration.color {
            setColor(color)
        }
        
        if let font = configuration.font {
            setFont(font)
        }
        
        if let placeholder = configuration.placeholder {
            setPlaceholder(placeholder)
        }
        
        if let border = configuration.border {
            setBorder(border)
        }
    }
    
}

extension PlaceholderTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        togglePlaceholder()
        delegate?.placeholderTextView(self, didChangeWith: textView.text)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        togglePlaceholder()
        delegate?.placeholderTextView(self, didEndEditingWith: textView.text)
    }
    
    private func togglePlaceholder() {
        placeholderLabel.isHidden = !self.textView.text.isEmpty
    }
}

extension PlaceholderTextView {
    private func setText(_ text: String) {
        self.textView.text = text
        togglePlaceholder()
    }
    
    private func setPlaceholder(_ placeholder: String) {
        placeholderLabel.text = placeholder
    }
    
    private func setFont(_ font: UIFont) {
        textView.font = font
        placeholderLabel.font = font
    }
    
    private func setColor(_ color: UIColor) {
        textView.textColor = color
    }
    
    private func setBorder(_ border: Configuration.Border) {
        textView.drawBorder(width: border.width, color: border.color)
    }
}
