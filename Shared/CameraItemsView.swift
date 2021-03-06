//
//  CameraItemsView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI

struct CameraItemsView: View {
    @ObservedObject var cameraDevice: CameraDevice
    var body: some View {
        VStack(alignment: .leading)
        {   
            List 
            {
                Text(NSLocalizedString("Camera Items", comment: ""))
                    .font(.title)
                ForEach((0..<cameraDevice.mediaFiles.count), id: \.self) { index in
                    MediaItemView(mediaFile: cameraDevice.mediaFiles[index])
                }
            }
            Spacer()
        }
        
    }
}

struct CameraItemsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraItemsView(cameraDevice: CameraDevice.exampleDevice)
    }
}
