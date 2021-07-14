//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import AVFoundation
import NotificareKit
import UIKit

private let kCrosshairMarginHorizontal: CGFloat = 20.0
private let kCrosshairMarginVertical: CGFloat = 100.0

internal class NotificareQrCodeScannerViewController: UIViewController {
    typealias OnQrCodeDetected = (_ qrCode: String) -> Void

    private let captureSession = AVCaptureSession()
    private var detectedQrCode = false

    var onQrCodeDetected: OnQrCodeDetected?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NotificareUtils.applicationName
        navigationController?.isNavigationBarHidden = false

        setupCaptureSession()
        setupCrosshair()

        captureSession.startRunning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func setupCaptureSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            NotificareLogger.warning("Failed to acquire the default device for video.")
            return
        }

        let input: AVCaptureDeviceInput

        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            NotificareLogger.warning("Failed to get input device for video.\n\(error)")
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            NotificareLogger.warning("Unable to add video input to capture session.")
            return
        }

        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)

            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        } else {
            NotificareLogger.warning("Unable to add video input to capture session.")
            return
        }

        // Add the preview layer to the view.
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds

        // Add the preview layer to the view.
        view.layer.addSublayer(previewLayer)
    }

    private func setupCrosshair() {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0

        let crosshair = UIView(
            frame: CGRect(
                x: kCrosshairMarginHorizontal,
                y: kCrosshairMarginVertical + navbarHeight,
                width: view.frame.width - kCrosshairMarginHorizontal * 2,
                height: view.frame.height - kCrosshairMarginVertical * 2
            )
        )

        crosshair.translatesAutoresizingMaskIntoConstraints = false
        crosshair.layer.borderColor = UIColor.green.cgColor
        crosshair.layer.borderWidth = 1.0
        crosshair.layer.backgroundColor = UIColor.clear.cgColor

        // Add the crosshair to the view.
        view.addSubview(crosshair)

        // Setup the preview layer UI constraints.
        crosshair.topAnchor.constraint(equalTo: view.topAnchor, constant: kCrosshairMarginVertical).isActive = true
        crosshair.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: kCrosshairMarginHorizontal).isActive = true
        crosshair.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kCrosshairMarginHorizontal).isActive = true
        crosshair.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -kCrosshairMarginVertical).isActive = true
    }
}

extension NotificareQrCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        metadataObjects.forEach { metadata in
            if let metadata = metadata as? AVMetadataMachineReadableCodeObject,
               let qrCode = metadata.stringValue,
               !detectedQrCode
            {
                detectedQrCode = true
                captureSession.stopRunning()

                self.onQrCodeDetected?(qrCode)
            }
        }
    }
}
