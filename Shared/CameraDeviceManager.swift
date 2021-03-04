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

private extension CameraDeviceManager
{
    func openSessionIfPossible(onCameraDevice cameraDevice: ICCameraDevice)
    {
        // sanity check
        if cameraDevice.hasOpenSession { return }
        
        cameraDevice.requestOpenSession(options: nil) { (error: Error?) in
            if let anError = error
            {
                print("ERROR opening session on camera: \(anError)")
                
                let nsError: NSError = anError as NSError
                if let code = ICReturnConnectionError.Code(rawValue: nsError.code)
                {
                    switch code
                    {
                    case .sessionAlreadyOpen: print("sessionAlreadyOpen")
                    case .closedSessionSuddenly: print("closedSessionSuddenly")
                    case .driverExited: print("driverExited")
                    case .ejectFailed: print("ejectFailed")
                    case .ejectedSuddenly: print("ejectedSuddenly")
                    case .failedToOpen: print("failedToOpen")
                    case .notAuthorizedToOpenDevice:print("notAuthorizedToOpenDevice")
                    case .failedToOpenDevice: print("failedToOpenDevice")
                    @unknown default: print("unknown default")
                    }
                }
                else
                {
                    print("Error code is not of type ICReturnConnectionError.Code. Find out what it actually is in `ImageCaptureConstants.h`")
                }
            }
            else
            {
                print("SUCCESS! opening a session")
            }
        }
    }
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
            
            cameraDevice.delegate = self
            if !cameraDevice.hasOpenSession
            {
                openSessionIfPossible(onCameraDevice: cameraDevice)
            }
            else
            {
            }
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

extension CameraDeviceManager: ICCameraDeviceDelegate
{    
    func cameraDeviceDidRemoveAccessRestriction(_ device: ICDevice)
    {
        print("\(#function)")
        if let cameraDevice = device as? ICCameraDevice
        {
            if !cameraDevice.hasOpenSession
            {
                if !cameraDevice.isAccessRestrictedAppleDevice
                {
                    openSessionIfPossible(onCameraDevice: cameraDevice)
                }
            }
            else
            {
            }
        }
    }
    func cameraDeviceDidEnableAccessRestriction(_ device: ICDevice)
    {
        print("\(#function)")
    }
    func device(_ device: ICDevice,
                didCloseSessionWithError error: Error?)
    {
        print("\(#function)")
    }
    
    func cameraDevice(_ camera: ICCameraDevice,
                      didReceiveThumbnail thumbnail: CGImage?,
                      for item: ICCameraItem,
                      error: Error?)
    { /* print("\(#function)") */ }
    
    func cameraDevice(_ camera: ICCameraDevice, didAdd items: [ICCameraItem])  {}
    func cameraDevice(_ camera: ICCameraDevice, didRemove items: [ICCameraItem]) {}
    func cameraDevice(_ camera: ICCameraDevice, didReceiveMetadata metadata: [AnyHashable : Any]?, for item: ICCameraItem, error: Error?)  {}
    func cameraDevice(_ camera: ICCameraDevice, didRenameItems items: [ICCameraItem]) {}
    func cameraDeviceDidChangeCapability(_ camera: ICCameraDevice) {}
    func cameraDevice(_ camera: ICCameraDevice, didReceivePTPEvent eventData: Data) {}
    func didRemove(_ device: ICDevice) {}
    
    ///////////////    
    func device(_ device: ICDevice, didOpenSessionWithError error: Error?) 
    {
        print("\(type(of: self)) - \(#function)")
        updateOrCreateCameraDevice(for: device)
    }
    
    func deviceDidBecomeReady(withCompleteContentCatalog device: ICCameraDevice) 
    {
        print("\(type(of: self)) - \(#function)")
        updateOrCreateCameraDevice(for: device)
    }
    private func updateOrCreateCameraDevice(for device: ICDevice)
    {
        print("\(type(of: self)) - \(#function)")
        if let iCCameraDevice = device as? ICCameraDevice
        {
            if let cameraDevice = iCCameraDevice.userData?[CameraDevice.CameraDeviceKey] as? CameraDevice
            {
                cameraDevice.update(with: iCCameraDevice)
            }
            else 
            {
                iCCameraDevice.userData?[CameraDevice.CameraDeviceKey] = CameraDevice(cameraDevice: iCCameraDevice) 
            }
        } 
    }
}

class CameraDevice: Identifiable, ObservableObject
{
    fileprivate static let CameraDeviceKey = "CameraDevice"
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
    @Published var mediaFiles: [CameraItem] = []
}
extension CameraDevice: Equatable
{
    static func == (lhs: CameraDevice, 
                    rhs: CameraDevice) -> Bool  { return lhs === rhs }    
}

private extension CameraDevice
{
    convenience init(cameraDevice: ICCameraDevice)
    {     
        self.init()
        
        assert(nil != cameraDevice.userData, "Something changed in ImageCaptureCore? If so, we need to maintain a link between ICCameraDevice and CameraDevice ourselves.")
        cameraDevice.userData?[CameraDevice.CameraDeviceKey] = self
        update(with: cameraDevice)
    }
    func update(with iCCameraDevice: ICCameraDevice)
    {
        guard let userData = iCCameraDevice.userData
        else { fatalError("Something changed in ImageCaptureCore? If so, we need to maintain a link between ICCameraDevice and CameraDevice ourselves.") }
        
        guard let cameraDevice = userData[CameraDevice.CameraDeviceKey] as? CameraDevice 
        else { fatalError("Unexpected type or nil for `\(CameraDevice.CameraDeviceKey)`") }
        
        assert(cameraDevice == self, "Updating a `\(type(of: self))` with an `\(type(of: iCCameraDevice))` that it was not initialized with")
        
        name = iCCameraDevice.name ?? NSLocalizedString("No Name", comment: "")
        isAccessRestrictedAppleDevice = iCCameraDevice.isAccessRestrictedAppleDevice
        productKind = {
            switch iCCameraDevice.productKind 
            {
            case "iPhone": return .iPhone 
            case "iPod": return .iPod
            case "iPad": return .iPad
            case "Camers": return .camera
            case "Scanner": return .scanner
            default: return .camera
            }
        }()
        id = iCCameraDevice.uuidString ?? id
        
        if let iCMediaFiles = iCCameraDevice.mediaFiles
        {
            for anICCameraItem in iCMediaFiles
            {
                if let _ = anICCameraItem.userData?[CameraItem.CameraItemKey] as? CameraItem
                {
                    // CameraItem already exists
                }
                else 
                {
                    let newCameraItem = CameraItem(cameraItem: anICCameraItem, 
                                                   cameraDevice: self)
                    anICCameraItem.userData?[CameraItem.CameraItemKey] = newCameraItem
                    mediaFiles.append(newCameraItem)
                }
            }
        }
    }
}

class CameraItem: Identifiable, ObservableObject
{
    fileprivate static let CameraItemKey = "CameraItem"
    
    fileprivate unowned var cameraDevice: CameraDevice? = nil
    @Published var name: String? = nil
    @Published var isLocked: Bool
    @Published var isRaw: Bool 
    @Published var creationDate: Date?
    @Published var modificationDate: Date?
    @Published var thumbnail: CGImage?
    
    fileprivate init(cameraItem: ICCameraItem, cameraDevice: CameraDevice)
    {     
        self.cameraDevice = cameraDevice
        name = cameraItem.name
        isLocked = cameraItem.isLocked
        isRaw = cameraItem.isRaw
        creationDate = cameraItem.creationDate
        modificationDate = cameraItem.modificationDate
        thumbnail = cameraItem.thumbnail
        cameraItem.userData?[CameraItem.CameraItemKey] = self
    } 
}


extension CameraItem
{
    static var exampleItem: CameraItem 
    { CameraItem() }
    
    private convenience init()
    {
        self.init(cameraItem: ICCameraItem(), 
                  cameraDevice: CameraDevice())
        name = "IMG_2449.jpg"
        isLocked = false
        isRaw = false
        
        let now = Date()
        creationDate = now
        modificationDate = now
        thumbnail = nil
    }
}
