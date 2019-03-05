//
//  SelectField.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol SelectedFieldDelegate: class {
    func selectedField(_ selectedField: SelectField, didSelectedChoice choice: String)
}

public class SelectField: UIView, XibInitializable {
    
    @IBInspectable public var borderColor: UIColor = .clear {
        didSet { drawBorder(width: borderWidth, color: borderColor) }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet { drawBorder(width: borderWidth, color: borderColor) }
    }
    
    @IBInspectable public var margin: CGFloat = 0.0 {
        didSet {
            topMarginConstraint.constant = margin
            leftMarginConstraint.constant = margin
            bottomMarginConstraint.constant = margin
        }
    }
    
    @IBInspectable public var text: String = "選択してください" {
        didSet {
            label.text = text
        }
    }
    
    @IBInspectable public var selectTitle: String?
    @IBInspectable public var selectMessage: String?
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            defaultText = label.text
            defaultLabelColor = label.textColor
        }
    }
    private var defaultText: String?
    private var defaultLabelColor: UIColor?
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
    
    public weak var delegate: SelectedFieldDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setXibView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setXibView()
    }
    
    private var choices: [String] = []
    private var selectedChoice: String? {
        didSet {
            if let selectedChoice = selectedChoice {
                label.text = selectedChoice
                label.textColor = .black
            } else {
                label.text = selectedChoice
                label.textColor = defaultLabelColor
            }
        }
    }
    
    @discardableResult
    public func configure(with choices: [String]) -> Self {
        self.choices = choices
        return self
    }

    @IBAction func didTappedView(_ sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: selectTitle,
                                            message: selectMessage,
                                            preferredStyle: .actionSheet)
        choices
            .map { choice -> UIAlertAction in
                return UIAlertAction(title: choice, style: .default) { [weak self] (action) in
                    guard let self = self else { return }
                    self.selectedChoice = choice
                    self.delegate?.selectedField(self, didSelectedChoice: choice)
                    AlertController.done()
                }
            }
            .forEach {
                actionSheet.addAction($0)
            }
        
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            AlertController.done()
        })
        
        
        AlertController.show(actionSheet)
    }
}
