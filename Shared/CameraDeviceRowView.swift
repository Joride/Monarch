//
//  CameraDeviceRowView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 02/03/2021.
//

import SwiftUI

struct CameraDeviceRowView: View 
{
    @Binding var cameraDevice: CameraDevice
    var body: some View {
        HStack
        {
            Image(systemName: cameraDevice.productKind.rawValue)
                .font(.largeTitle)
            
            VStack(alignment: .leading)
            {
                Text(cameraDevice.name)
                    .font(.title)
                Image(systemName: "lock")
                    .font(.largeTitle)
            }
            Spacer()
        }
        .padding()
    }
}

struct CameraDeviceRowView_Previews: PreviewProvider {
    static var previews: some View {
        CameraDeviceRowView(cameraDevice: .constant(CameraDevice()))
    }
}
