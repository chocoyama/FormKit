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
    @IBOutlet weak var textInputField1: TextInputField!
    @IBOutlet weak var textInputField2: TextInputField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField1()
        configureTextField2()
    }
    
    private func configureTextField1() {
        var configuration = TextInputField.Configuration()
        configuration.layout.axis = .horizontal
        textInputField1.configure(with: configuration)
    }
    
    private func configureTextField2() {
        var configuration = TextInputField.Configuration()
        
        // layout
        configuration.layout.axis = .vertical
        configuration.layout.margin = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        configuration.layout.spacing = 4.0
        
        // title
        configuration.title.value = "住所"
        
        // inputField
        configuration.inputField.placeholder = "〒101-0001"
        configuration.inputField.border = (color: UIColor(white: 0.3, alpha: 0.4), width: 1.0)
        
        textInputField2.configure(with: configuration)
    }
}

