//
//  Camera.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import AVFoundation

class Camera {
    private let settings: Settings
    
    private var session: AVCaptureSession?
    private var device: Device
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(settings: Settings) {
        self.settings = settings
        self.device = Device()
    }
    
    func prepare() {
        createSession()
        setUpDevice()
        
        if let session = session, let device = getInitialDevice() {
            setUpInput(for: session, with: device)
            setUpPhotoOutput(for: session, completionHandler: nil)
            setUpPreviewLayer(for: session)
        }
    }
    
    func set(to view: UIView) {
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = view.frame
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func start() {
        session?.startRunning()
    }
    
    func stop() {
        session?.stopRunning()
    }
}

extension Camera {
    private func createSession() {
        session = AVCaptureSession()
        session?.sessionPreset = settings.session.preset
    }
    
    private func setUpDevice() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: settings.input.deviceTypes,
            mediaType: settings.input.mediaType,
            position: settings.input.position
        )
        
        discoverySession.devices.forEach {
            switch $0.position {
            case .unspecified: break
            case .back: device.back = $0
            case .front: device.front = $0
            }
        }
    }
    
    private func getInitialDevice() -> AVCaptureDevice? {
        if let preferredDevice = device.get(position: settings.input.preferredPosition) {
            return preferredDevice
        } else if let current = device.current {
            return current
        } else {
            return nil
        }
    }
    
    private func setUpInput(for session: AVCaptureSession, with device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch let error {
            print(error)
        }
    }
    
    private func setUpPhotoOutput(for session: AVCaptureSession,
                                  completionHandler: ((Bool, Error?) -> Void)?) {
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.setPreparedPhotoSettingsArray(settings.output.photoSettings, completionHandler: completionHandler)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }
    
    private func setUpPreviewLayer(for session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = settings.layer.videoGravity
        previewLayer?.connection?.videoOrientation = settings.layer.orientation
    }
}

extension Camera {
    struct Settings {
        struct Session {
            let preset: AVCaptureSession.Preset
        }
        
        struct Input {
            let deviceTypes: [AVCaptureDevice.DeviceType]
            let mediaType: AVMediaType?
            let position: AVCaptureDevice.Position
            let preferredPosition: Device.Position
        }
        
        struct Output {
            let photoSettings: [AVCapturePhotoSettings]
        }
        
        struct Layer {
            let videoGravity: AVLayerVideoGravity
            let orientation: AVCaptureVideoOrientation
        }
        
        let session: Session
        let input: Input
        let output: Output
        let layer: Layer
    }
    
    struct Device {
        enum Position {
            case back
            case front
        }
        
        fileprivate var back: AVCaptureDevice?
        fileprivate var front: AVCaptureDevice?
        
        var current: AVCaptureDevice? {
            if let back = back {
                return back
            } else if let front = front {
                return front
            } else {
                return nil
            }
        }
        
        func get(position: Position) -> AVCaptureDevice? {
            switch position {
            case .back: return back
            case .front: return front
            }
        }
    }
}
