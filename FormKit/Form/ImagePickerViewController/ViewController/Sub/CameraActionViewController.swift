//
//  CameraActionViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/17.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol CameraActionViewControllerDelegate: class {
    func cameraActionViewController(_ cameraActionViewController: CameraActionViewController, didTappedCameraView tapGesture: UITapGestureRecognizer)
    func cameraActionViewController(_ cameraActionViewController: CameraActionViewController, didTappedReverseButton button: UIButton)
}

public class CameraActionViewController: UIViewController, Pageable {

    var pageNumber: Int = 0
    
    public weak var delegate: CameraActionViewControllerDelegate?
    
    @IBOutlet weak var cameraContainerView: UIView! {
        didSet {
            cameraContainerView
                .drawBorder(width: 1.0, color: .black)
                .rounded()
        }
    }
    
    init() {
        super.init(nibName: String(describing: CameraActionViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didTappedCameraView(_ sender: UITapGestureRecognizer) {
        delegate?.cameraActionViewController(self, didTappedCameraView: sender)
    }
    
    @IBAction func didTappedReverseButton(_ sender: UIButton) {
        delegate?.cameraActionViewController(self, didTappedReverseButton: sender)
    }
}
