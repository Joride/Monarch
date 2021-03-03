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
            HStack {
                Text(NSLocalizedString("Devices", comment: ""))
                    .font(.title)
                Spacer()
            }
            
            ForEach((0..<cameraDevices.count), id: \.self) {
                CameraDeviceRowView(cameraDevice: $cameraDevices[$0])
            }
            Spacer()
        }
        .padding()
    }
}

struct CameraDeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        CameraDeviceListView(cameraDevices: .constant([CameraDevice(),
                                                       CameraDevice()]))
    }
}
