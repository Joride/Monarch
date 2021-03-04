//
//  ViewController.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 23/02/2021.
//

import Cocoa
import ImageCaptureCore

class ViewController: NSViewController
{
    private let deviceBrowser = ICDeviceBrowser()
    fileprivate let docDir: URL
    override init(nibName nibNameOrNil: NSNib.Name?,
                  bundle nibBundleOrNil: Bundle?)
    {
        guard let docDir = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).last
        else { fatalError("No documents directory?") }
        self.docDir = docDir

        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
        
        print("\(docDir.path)\n")
        deviceBrowser.delegate = self
        deviceBrowser.start()
    }
    
    required init?(coder: NSCoder)
    {
        guard let docDir = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).last
        else { fatalError("No documents directory?") }
        self.docDir = docDir
        
        super.init(coder: coder)
        
        print(docDir.path)
        deviceBrowser.delegate = self
        deviceBrowser.start()
    }
    
    fileprivate var cameraDevices: [ICCameraDevice] = []
}

// MARK: - Device Handling
private extension ViewController
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
// MARK: - File Handling
private extension ViewController
{
    func downloadFiles(from cameraDevice: ICCameraDevice)
    {
        if let mediaFiles = cameraDevice.mediaFiles
        {
            for aMediaFile in mediaFiles
            {
                if let cameraFile = aMediaFile as? ICCameraFile
                {
                    guard let fileName = cameraFile.name
                    else  { fatalError("ERROR: a camerafile without name") }
                    
                    /// `.deleteAfterSuccessfulDownload` does not work. Instrad
                    /// files are requested to be deleted after a succesful download
                    let options: [ICDownloadOption : Any]  =
                        [.deleteAfterSuccessfulDownload : NSNumber(booleanLiteral: true),
                         .downloadsDirectoryURL : docDir,
                         .saveAsFilename: fileName,
                         .overwrite: NSNumber(booleanLiteral: false),
                         .sidecarFiles: NSNumber(booleanLiteral: true),
                        ]
                    let didDownloadSelector = #selector(ViewController.didDownloadFile(_:error:options:contextInfo:))
                    cameraDevice.requestDownloadFile(cameraFile,
                                                     options: options,
                                                     downloadDelegate: self,
                                                     didDownloadSelector: didDownloadSelector,
                                                     contextInfo: nil)
                }
            }
        }
        else
        { /* No images on this camera */ }
    }
}

// MARK: -
extension ViewController: ICDeviceBrowserDelegate
{
    func deviceBrowser(_ browser: ICDeviceBrowser,
                       didAdd device: ICDevice,
                       moreComing: Bool)
    {
        if let cameraDevice = device as? ICCameraDevice
        {
            cameraDevice.delegate = self

            if !cameraDevice.hasOpenSession
            {
                openSessionIfPossible(onCameraDevice: cameraDevice)
            }
            else
            {
                if !cameraDevices.contains(cameraDevice)
                {
                    cameraDevices.append(cameraDevice)
                }
                downloadFiles(from: cameraDevice)
            }
        }
        else  { /* not a camera device, ignore it */ }
    }
    
    func deviceBrowser(_ browser: ICDeviceBrowser,
                       didRemove device: ICDevice,
                       moreGoing: Bool)
    {
        device.delegate = nil
        cameraDevices.removeAll {
            (cameraDevice: ICCameraDevice) -> Bool in
            return cameraDevice == device
        }
    }
}

extension ViewController: ICCameraDeviceDelegate
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
                if !cameraDevices.contains(cameraDevice)
                {
                    cameraDevices.append(cameraDevice)
                }
                downloadFiles(from: cameraDevice)
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
    
    func device(_ device: ICDevice,
                didOpenSessionWithError error: Error?)
    {
        print("\(#function)")
    }
    
    func deviceDidBecomeReady(withCompleteContentCatalog device: ICCameraDevice)
    {
        if !cameraDevices.contains(device)
        {
            cameraDevices.append(device)
        }
        downloadFiles(from: device)
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
}

extension ViewController: ICCameraDeviceDownloadDelegate
{
    func didDownloadFile(_ file: ICCameraFile,
                         error: Error?,
                         options: [String : Any] = [:],
                         contextInfo: UnsafeMutableRawPointer?)
    {
        if let anError = error
        {
            print("ERROR downloading file: \(anError)")
        }
        else
        {
            print("SUCCES downloading file!")
//            file.device?.requestDeleteFiles([file])
        }
    }
}
