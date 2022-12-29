//
//  PhotoPickerView.swift
//  AiDraw
//
//  Created by Kiet Ho on 12/29/22.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    let photoImportedHandler: (Data) -> Void

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Image(systemName: "photo.on.rectangle.angled")
        }.onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoImportedHandler(data)
                }
            }
        }
    }
}

func mockPhotoImportedHandler(data: Data) {}
struct PhotoPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView(photoImportedHandler: mockPhotoImportedHandler)
    }
}
