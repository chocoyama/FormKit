//
//  CameraViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/17.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func cameraViewController(_ cameraViewController: CameraViewController, didCapturedImage image: UIImage)
}

class CameraViewController: UIViewController, Pageable {
    var pageNumber = 0
    
    weak var delegate: CameraViewControllerDelegate?
    
    let camera = Camera(settings: .init(
        session: .init(
            preset: .photo
        ),
        input: .init(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified,
            preferredPosition: .front
        ),
        output: .init(
            preparedPhotoSettingsArray: [
                AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
            ],
            captureSettings: {
                let settings = AVCapturePhotoSettings()
                settings.flashMode = .auto
                settings.isAutoStillImageStabilizationEnabled = true
                return settings
            }()
        ),
        layer: .init(
            videoGravity: .resizeAspectFill,
            orientation: .portrait
        )
    ))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !camera.isRunning {
            camera.launch(on: view)
        }
    }
    
    func capturePhoto() {
        camera.capture { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.delegate?.cameraViewController(self, didCapturedImage: image)
            case .failure:
                break
            }
        }
    }
    
    func reverseCamera() {
        camera.reverse()
    }
}
