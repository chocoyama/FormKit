//
//  SubmitButton.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

@IBDesignable
class SubmitButton: UIView, XibInitializable {

    @IBOutlet weak var button: UIButton!
    
    @IBInspectable public var buttonTitle: String = "Submit" {
        didSet {
            button.setTitle(buttonTitle, for: .normal)
        }
    }
    
    @IBInspectable public var buttonTitleColor: UIColor = .black {
        didSet {
            button.setTitleColor(buttonTitleColor, for: .normal)
        }
    }
    
    @IBInspectable public var buttonBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = buttonBackgroundColor
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

}
