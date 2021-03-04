//
//  MonarchApp.swift
//  Shared
//
//  Created by Jorrit van Asselt on 02/03/2021.
//

import SwiftUI

@main
struct MonarchApp: App
{    
    @StateObject private var cameraDevicesManager = CameraDeviceManager()
    var body: some Scene 
    {
        WindowGroup 
        {
            ContentView()
                .environmentObject(cameraDevicesManager)
        }
    }
}
