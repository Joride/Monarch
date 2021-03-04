//
//  ContentView.swift
//  Shared
//
//  Created by Jorrit van Asselt on 02/03/2021.
//

import SwiftUI

struct ContentView: View 
{
    @EnvironmentObject private var cameraDevicesManager: CameraDeviceManager
    var body: some View 
    {   
        NavigationView
        {
            CameraDeviceListView(cameraDevices: $cameraDevicesManager.cameraDevices)
        }
        .onAppear { cameraDevicesManager.start() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View 
    {
        ContentView()
    }
}
