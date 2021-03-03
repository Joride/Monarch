//
//  CameraDeviceManager.swift
//  Monarch (macOS)
//
//  Created by Jorrit van Asselt on 01/03/2021.
//

import ImageCaptureCore
import Combine

class CameraDeviceManager: NSObject, ObservableObject
{
    @Published var cameraDevices: [CameraDevice] = []
    
    private lazy var deviceBrowser: ICDeviceBrowser = {
        let deviceBrowser = ICDeviceBrowser()
        deviceBrowser.delegate = self
        return deviceBrowser
    }()
    
    func start() { deviceBrowser.start() }
    func stop() { deviceBrowser.stop() }
}

extension CameraDeviceManager: ICDeviceBrowserDelegate
{
    func deviceBrowser(_ browser: ICDeviceBrowser,
                       didAdd device: ICDevice,
                       moreComing: Bool)
    {
        print("\(type(of: self)) - \(#function)")
        if let cameraDevice = device as? ICCameraDevice
        {
            let camera = CameraDevice(cameraDevice: cameraDevice)
            cameraDevices.append(camera)
        }
    }
    
    func deviceBrowser(_ browser: ICDeviceBrowser,
                       didRemove device: ICDevice,
                       moreGoing: Bool)
    {
        print("\(type(of: self)) - \(#function)")	
        if let cameraDevice = device as? ICCameraDevice,
           let cameraId = cameraDevice.uuidString
        {   
            cameraDevices.removeAll { $0.id == cameraId }
        }
    }
}

class CameraDevice: Identifiable, ObservableObject
{
    enum ProductKind: String, CaseIterable
    {
        case iPhone = "iphone"
        case iPod = "ipod"
        case iPad = "ipad"
        case camera = "camera"
        case scanner = "scanner"
    }
    
    var id: String = UUID().uuidString
    @Published var name: String = NSLocalizedString("No Name", comment: "")
    @Published var productKind: CameraDevice.ProductKind = .camera
    @Published var isAccessRestrictedAppleDevice: Bool = false
}
private extension CameraDevice
{
    convenience init(cameraDevice: ICCameraDevice)
    {     
        self.init()
        name = cameraDevice.name ?? NSLocalizedString("No Name", comment: "")
        isAccessRestrictedAppleDevice = cameraDevice.isAccessRestrictedAppleDevice
        productKind = {
            switch cameraDevice.productKind 
            {
            case "iPhone": return .iPhone 
            case "iPod": return .iPod
            case "iPad": return .iPad
            case "Camers": return .camera
            case "Scanner": return .scanner
            default: return .camera
            }
        }()
        id = cameraDevice.uuidString ?? id
    }
}
