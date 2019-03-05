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
    @IBOutlet weak var prefectureSelectField: SelectField! {
        didSet {
            prefectureSelectField.configure(with: [
                "東京",
                "神奈川",
                "千葉",
                "埼玉",
                "群馬",
                "栃木",
                "茨城"
            ])
        }
    }
}

