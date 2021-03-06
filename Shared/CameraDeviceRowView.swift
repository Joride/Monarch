//
//  CameraDeviceRowView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 02/03/2021.
//

import SwiftUI
import ImageCaptureCore

struct CameraDeviceRowView: View 
{
    @ObservedObject var cameraDevice: CameraDevice
    var body: some View {
        HStack
        {
            Image(systemName: cameraDevice.productKind.rawValue)
                .font(.largeTitle)
            
            VStack(alignment: .leading)
            {
                Text(cameraDevice.name)
                    .font(.title)
                if cameraDevice.isAccessRestrictedAppleDevice
                {
                    Image(systemName: "lock")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                else 
                {
                    Image(systemName: "lock.open")
                        .font(.largeTitle)    
                        .foregroundColor(.green)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct CameraDeviceRowView_Previews: PreviewProvider {
    static var previews: some View {
        CameraDeviceRowView(cameraDevice: CameraDevice.exampleDevice)
    }
}
