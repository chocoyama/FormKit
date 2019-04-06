//
//  Camera.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import AVFoundation

class Camera: NSObject {
    private let settings: Settings
    
    private var session: AVCaptureSession?
    private var device: Device?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentInput: AVCaptureDeviceInput?
    private var currentPhotoOutput: AVCapturePhotoOutput?
    
    var isRunning: Bool {
        return session?.isRunning ?? false
    }
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    deinit {
        stop()
        resetInput()
        resetOutput()
    }
    
    func prepare() {
        createSession()
        setUpDevice()
        
        if let session = session, let device = device?.current {
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
    
    func capture() {
        currentPhotoOutput?.capturePhoto(with: settings.output.captureSettings,
                                         delegate: self)
    }
    
    func reverse() {
        if let session = session, let reversedDevice = device?.reverse() {
            resetInput()
            setUpInput(for: session, with: reversedDevice)
        }
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
        device = Device(devices: discoverySession.devices,
                        preferredPosition: .back)
    }
    
    private func setUpInput(for session: AVCaptureSession, with device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            currentInput = input
        } catch let error {
            print(error)
        }
    }
    
    private func resetInput() {
        guard let input = currentInput else { return }
        session?.removeInput(input)
        currentInput = nil
    }
    
    private func setUpPhotoOutput(for session: AVCaptureSession,
                                  completionHandler: ((Bool, Error?) -> Void)?) {
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.setPreparedPhotoSettingsArray(settings.output.preparedPhotoSettingsArray, completionHandler: completionHandler)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        currentPhotoOutput = photoOutput
    }
    
    private func resetOutput() {
        guard let output = currentPhotoOutput else { return }
        session?.removeOutput(output)
        currentPhotoOutput = nil
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
            let preparedPhotoSettingsArray: [AVCapturePhotoSettings]
            let captureSettings: AVCapturePhotoSettings
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
        
        fileprivate let back: AVCaptureDevice?
        fileprivate let front: AVCaptureDevice?
        private(set) var current: AVCaptureDevice?
        
        init(devices: [AVCaptureDevice], preferredPosition: Position) {
            var back: AVCaptureDevice?
            var front: AVCaptureDevice?
            devices.forEach {
                switch $0.position {
                case .unspecified: break
                case .back: back = $0
                case .front: front = $0
                @unknown default: fatalError()
                }
            }
            
            self.back = back
            self.front = front
            
            if let prefferedDevice = get(position: preferredPosition) {
                current = prefferedDevice
            } else if let back = get(position: .back) {
                current = back
            } else if let front = get(position: .front)  {
                current = front
            }
        }
        
        mutating func reverse() -> AVCaptureDevice? {
            if current == back {
                current = front
            } else if current == front {
                current = back
            }
            return current
        }
        
        func get(position: Position) -> AVCaptureDevice? {
            switch position {
            case .back: return back
            case .front: return front
            }
        }
    }
}
