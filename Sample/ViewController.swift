//
//  ViewController.swift
//  Sample
//
//  Created by Takuya Yokoyama on 2019/02/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import FormKit

class ViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.alwaysBounceVertical = true
        }
    }
    
    @IBOutlet weak var lastNameInputField: TextInputField!
    @IBOutlet weak var firstNameInputField: TextInputField!
    @IBOutlet weak var postalCodeInputField: TextInputField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLastNameInputField()
        configureFirstNameInputField()
        configureAddressInputField()
    }
    
    private func configureLastNameInputField() {
        var configuration = TextInputField.Configuration()
        
        // layout
        configuration.layout.spacing = 4.0
        
        // inputField
        configuration.inputField.placeholder = "姓"
        configuration.inputField.border = (color: UIColor(white: 0.3, alpha: 0.4), width: 1.0)
        
        // validation
        configuration.validation.maxInputCount = nil
        
        lastNameInputField.configure(with: configuration)
    }
    
    private func configureFirstNameInputField() {
        var configuration = TextInputField.Configuration()
        
        // layout
        configuration.layout.spacing = 4.0
        
        // inputField
        configuration.inputField.placeholder = "名"
        configuration.inputField.border = (color: UIColor(white: 0.3, alpha: 0.4), width: 1.0)
        
        // validation
        configuration.validation.maxInputCount = nil
        
        firstNameInputField.configure(with: configuration)
    }
    
    private func configureAddressInputField() {
        var configuration = TextInputField.Configuration()
        
        // layout
        configuration.layout.axis = .vertical
        configuration.layout.spacing = 4.0
        
        // inputField
        configuration.inputField.placeholder = "〒101-0001"
        configuration.inputField.border = (color: UIColor(white: 0.3, alpha: 0.4), width: 1.0)
        
        // validation
        configuration.validation.maxInputCount = nil
        
        postalCodeInputField.configure(with: configuration)
    }
}

