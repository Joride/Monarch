//
//  CameraItemsView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI

struct CameraItemsView: View {
    
    @ObservedObject var cameraDevice: CameraDevice
    
    // The type of the Set depends on the type used to id: the items in the ForEach
    @State private var multiSelection = Set<CameraItem>()
    
    var body: some View {
        VStack(alignment: .leading)
        {   
            List(selection: $multiSelection)
            {
                Text(NSLocalizedString("Camera Items", comment: ""))
                    .font(.title)
                
                ForEach(cameraDevice.mediaFiles, id: \.self) { cameraItem in
                    MediaItemView(mediaFile: cameraItem)
                }
                
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem() {
                Button("Button 1") {}
            }
            
            ToolbarItem() {
                Button("Button 2") {}
            }
        }
        
    }
}

struct CameraItemsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraItemsView(cameraDevice: CameraDevice.exampleDevice)
    }
}
