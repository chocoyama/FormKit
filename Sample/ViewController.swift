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
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var imagePickerField: ImagePickerField! {
        didSet {
            imagePickerField.delegate = self
        }
    }
    @IBOutlet weak var lastNameInputField: TextInputField! {
        didSet {
            lastNameInputField.setTag(InputFieldTag.lastName)
            lastNameInputField.delegate = self
        }
    }
    @IBOutlet weak var firstNameInputField: TextInputField! {
        didSet {
            firstNameInputField.setTag(InputFieldTag.firstName)
            firstNameInputField.delegate = self
        }
    }
    @IBOutlet weak var postalCodeInputField: TextInputField! {
        didSet {
            postalCodeInputField.setTag(InputFieldTag.postalCode)
            postalCodeInputField.delegate = self
        }
    }
    @IBOutlet weak var postalCodeSubmitButton: SubmitButton! {
        didSet {
            postalCodeSubmitButton.setTag(SubmitButtonTag.postalCode)
            postalCodeSubmitButton.delegate = self
        }
    }
    @IBOutlet weak var prefectureSelectField: SelectField! {
        didSet {
            prefectureSelectField.configure(with: [
                "東京都",
                "神奈川県",
                "千葉県",
                "埼玉県",
                "群馬県",
                "栃木県",
                "茨城県"
            ])
            prefectureSelectField.delegate = self
        }
    }
    @IBOutlet weak var cityInputField: TextInputField! {
        didSet {
            cityInputField.setTag(InputFieldTag.city)
            cityInputField.delegate = self
        }
    }
    @IBOutlet weak var addressInputField: TextInputField! {
        didSet {
            addressInputField.setTag(InputFieldTag.address)
            addressInputField.delegate = self
        }
    }
    @IBOutlet weak var addressDetailInputField: TextInputField! {
        didSet {
            addressDetailInputField.setTag(InputFieldTag.addressDetail)
            addressDetailInputField.delegate = self
        }
    }
    @IBOutlet weak var phoneNumberInputField: TextInputField! {
        didSet {
            phoneNumberInputField.setTag(InputFieldTag.phoneNumber)
            phoneNumberInputField.delegate = self
        }
    }
    @IBOutlet weak var userSubmitButton: SubmitButton! {
        didSet {
            userSubmitButton.setTag(SubmitButtonTag.user)
            userSubmitButton.delegate = self
        }
    }
    
    
    private var userRegistrationForm = UserRegistrationForm()
}

extension ViewController: TextInputFieldDelegate {
    func textInputField(_ textInputField: TextInputField, didChangeWith text: String?) {
        
    }
    
    func textInputField(_ textInputField: TextInputField, didEndEditingWith text: String?) {
        guard let tag = InputFieldTag(rawValue: textInputField.tag) else { return }
        switch tag {
        case .lastName: userRegistrationForm.lastName = text
        case .firstName: userRegistrationForm.firstName = text
        case .postalCode: userRegistrationForm.postalCode = text
        case .city: userRegistrationForm.city = text
        case .address: userRegistrationForm.address = text
        case .addressDetail: userRegistrationForm.addressDetail = text
        case .phoneNumber: userRegistrationForm.phoneNumber = text
        }
        
        userSubmitButton.isEnabled = userRegistrationForm.isValid
    }
}

extension ViewController: SubmitButtonDelegate {
    func submitButton(_ submitButton: SubmitButton, didTappedButton button: UIButton) {
        guard let tag = SubmitButtonTag(rawValue: submitButton.tag) else { return }
        switch tag {
        case .postalCode:
            // Postal Code API Request
            break
        case .user:
            print(userRegistrationForm)
        }
    }
}

extension ViewController: SelectedFieldDelegate {
    func selectedField(_ selectedField: SelectField, didSelectedChoice choice: String) {
        userRegistrationForm.prefecture = choice
    }
}

extension ViewController: ImagePickerFieldDelegate {
    func imagePickerField(_ imagePickerField: ImagePickerField, didSelectAt indexPath: IndexPath, with imagePickerViewController: ImagePickerViewController) {
        imagePickerViewController.delegate = self
        present(imagePickerViewController, animated: true, completion: nil)
    }
}

extension ViewController: ImagePickerViewControllerDelegate {
    func imagePickerViewController(_ imagePickerViewController: ImagePickerViewController, didSelectedImages images: [PickedImage]) {
        userRegistrationForm.images = images.map { $0.image }
        imagePickerField?.set(images)
    }
}

extension ViewController {
    struct UserRegistrationForm {
        var images: [UIImage]?
        var lastName: String?
        var firstName: String?
        var postalCode: String?
        var prefecture: String?
        var city: String?
        var address: String?
        var addressDetail: String?
        var phoneNumber: String?
        
        var isValid: Bool {
            return images?.isEmpty == false
                && lastName?.isEmpty == false
                && firstName?.isEmpty == false
                && postalCode?.isEmpty == false
                && prefecture?.isEmpty == false
                && city?.isEmpty == false
                && address?.isEmpty == false
                && addressDetail?.isEmpty == false
                && phoneNumber?.isEmpty == false
        }
    }
    
    enum InputFieldTag: Int, Tag {
        case lastName
        case firstName
        case postalCode
        case city
        case address
        case addressDetail
        case phoneNumber
        
        var value: Int { return self.rawValue }
    }
    
    enum SubmitButtonTag: Int, Tag {
        case postalCode
        case user
        
        var value: Int { return self.rawValue }
    }
}


