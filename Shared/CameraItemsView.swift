//
//  CameraItemsView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI

struct CameraItemsView: View {
    @Binding var mediaItems:  [CameraItem]
    var body: some View {
        VStack(alignment: .leading)
        {   
            List 
            {
                Text(NSLocalizedString("Camera Items", comment: ""))
                    .font(.title)
                ForEach((0..<mediaItems.count), id: \.self) { index in
                    MediaItemView(mediaFile: mediaItems[index])
                }
            }
            Spacer()
        }
        
    }
}

struct CameraItemsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraItemsView(mediaItems: .constant([CameraItem.exampleItem]))
    }
}
