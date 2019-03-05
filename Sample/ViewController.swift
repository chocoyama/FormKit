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
    @IBOutlet weak var lastNameInputField: TextInputField!
    @IBOutlet weak var firstNameInputField: TextInputField!
    @IBOutlet weak var addressInputField: TextInputField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLastNameInputField()
        configureFirstNameInputField()
        configureAddressInputField()
    }
    
    private func configureLastNameInputField() {
        var configuration = TextInputField.Configuration()
        
        // layout
        configuration.layout.margin = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        configuration.layout.spacing = 4.0
        
        // title
        configuration.title.value = "お名前"
        
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
        configuration.layout.margin = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        configuration.layout.spacing = 4.0
        
        // title
        configuration.title.value = " "
        
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
        configuration.layout.margin = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        configuration.layout.spacing = 4.0
        
        // title
        configuration.title.value = "ご住所"
        
        // inputField
        configuration.inputField.placeholder = "〒101-0001"
        configuration.inputField.border = (color: UIColor(white: 0.3, alpha: 0.4), width: 1.0)
        
        // validation
        configuration.validation.maxInputCount = nil
        
        addressInputField.configure(with: configuration)
    }
}

