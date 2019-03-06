//
//  SubmitButton.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol SubmitButtonDelegate: class {
    func submitButton(_ submitButton: SubmitButton, didTappedButton button: UIButton)
}

@IBDesignable
public class SubmitButton: UIView, XibInitializable {

    @IBOutlet weak var button: UIButton!
    
    @IBInspectable public var title: String = "Submit" {
        didSet { button.setTitle(title, for: .normal) }
    }
    
    @IBInspectable public var fontSize: CGFloat = 17.0 {
        didSet { setFont(size: fontSize, isBold: isBold) }
    }
    
    @IBInspectable public var isBold: Bool = false {
        didSet { setFont(size: fontSize, isBold: isBold) }
    }
    
    public weak var delegate: SubmitButtonDelegate?
    
    private func setFont(size: CGFloat, isBold: Bool) {
        if isBold {
            button.titleLabel?.font = .boldSystemFont(ofSize: size)
        } else {
            button.titleLabel?.font = .systemFont(ofSize: size)
        }
    }
    
    @IBInspectable public var titleColor: UIColor = .black {
        didSet { button.setTitleColor(titleColor, for: .normal) }
    }
    
    @IBInspectable public var buttonBackgroundColor: UIColor = .white {
        didSet { button.backgroundColor = buttonBackgroundColor }
    }
    
    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            button.isUserInteractionEnabled = isEnabled
            button.backgroundColor = isEnabled ? buttonBackgroundColor : UIColor(red: 0.78, green: 0.78, blue: 0.81, alpha: 1.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }

    @IBAction func didTappedButton(_ sender: UIButton) {
        delegate?.submitButton(self, didTappedButton: sender)
    }
}
