//
//  CameraDeviceMediaItemsView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI

struct CameraDeviceMediaItemsView: View {
    var mediaItemNames = ["Item 1", "Item 2", "Item 3", "Item 4"]
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Text("Item")
            }
        }
        
    }
}

struct CameraDeviceMediaItemsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraDeviceMediaItemsView()
    }
}
