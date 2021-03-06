//
//  MediaItemView.swift
//  Monarch
//
//  Created by Jorrit van Asselt on 03/03/2021.
//

import SwiftUI

struct MediaItemView: View {
    var mediaFile: CameraItem
    var body: some View {
        Text(mediaFile.name)
    }
}

struct MediaItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaItemView(mediaFile: CameraItem.exampleItem)
    }
}
