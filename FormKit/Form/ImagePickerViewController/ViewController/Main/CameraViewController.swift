//
//  CameraViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/17.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, Pageable {
    var pageNumber = 0
    
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
            camera.prepare()
            camera.set(to: view)
            camera.start()
        }
    }
    
    func capturePhoto() {
        camera.capture()
    }
    
    func reverseCamera() {
        camera.reverse()
    }
}
