//
//  CameraPreviewView.swift
//  Flat
//
//  Created by xuyunshi on 2022/8/31.
//  Copyright © 2022 agora.io. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDeviceOrientation {
    func toInterfaceOrientation() -> UIInterfaceOrientation {
        switch self {
        case .unknown:
            return .unknown
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .faceUp:
            return .portrait
        case .faceDown:
            return .portrait
        @unknown default:
            return .portrait
        }
    }
}

private let sampleQueue = DispatchQueue(label: "io.agora.flat.preview")
class CameraPreviewView: UIView {
    init() {
        super.init(frame: .zero)
        setupViews()
        setupCapture()
        syncRotate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(syncRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func syncRotate() {
        func applicantionOrientation() -> UIInterfaceOrientation {
            if #available(iOS 13.0, *) {
                return (UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene)?.interfaceOrientation ?? .unknown
            } else {
                return UIApplication.shared.statusBarOrientation
            }
        }
        let isUnknown = UIDevice.current.orientation == .unknown
        let orientation: UIInterfaceOrientation =  isUnknown ? applicantionOrientation() : UIDevice.current.orientation.toInterfaceOrientation()
        switch orientation {
        case .unknown, .portrait:
            previewLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            previewLayer.connection?.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeLeft
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeRight
        @unknown default:
            previewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    func setupViews() {
        layer.addSublayer(previewLayer)
        previewLayer.videoGravity = .resizeAspectFill
        clipsToBounds = true
        layer.cornerRadius = 6
        
        addSubview(avatarContainer)
        avatarContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        avatarContainer.addSubview(avatarImageView)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        avatarImageView.kf.setImage(with: AuthStore.shared.user?.avatar)
    }
    
    var isOn = false
    
    func turnCamera(on: Bool) {
        if on == isOn { return }
        if on {
            session.startRunning()
            avatarContainer.isHidden = true
        } else {
            session.stopRunning()
            avatarContainer.isHidden = false
        }
        isOn = on
    }
    
    func setupCapture() {
        do {
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                logger.error("fetch camera fail")
                return
            }
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: sampleQueue)
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            output.connection(with: .video)?.isEnabled = true
        }
        catch {
            logger.error("setup capture error \(error)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
    
    lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBlueBar
        return view
    }()
    
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        return session
    }()
}

extension CameraPreviewView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}

