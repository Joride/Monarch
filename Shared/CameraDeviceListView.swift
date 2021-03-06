//
//  CameraDeviceListView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI
import ImageCaptureCore

struct CameraDeviceListView: View 
{
    @Binding var cameraDevices: [CameraDevice]
    var body: some View {
        VStack(alignment: .leading)
        {   
            List 
            {
                Text(NSLocalizedString("Devices", comment: ""))
                    .font(.title)
                
                ForEach((0..<cameraDevices.count), id: \.self) { index in
                    NavigationLink(destination: CameraItemsView(cameraDevice: cameraDevices[index])) {
                        CameraDeviceRowView(cameraDevice: cameraDevices[index])
                    }
                }
            }
            Spacer()
        }
    }
}

struct CameraDeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        CameraDeviceListView(cameraDevices: .constant([CameraDevice.exampleDevice,
                                                       CameraDevice.exampleDevice]))
    }
}
