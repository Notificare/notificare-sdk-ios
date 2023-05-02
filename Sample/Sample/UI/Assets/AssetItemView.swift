//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareAssetsKit
import NotificareKit
import SwiftUI

struct AssetItemView: View {
    var asset: NotificareAsset

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Group {
                if let urlStr = asset.url, let url = URL(string: urlStr) {
                    AsyncImageCompat(url: url) { image in
                        Image(uiImage: image)
                            .resizable()
                    } placeholder: {
                        Group {
                            Color.black.opacity(0.05)
                        }
                    }
                } else {
                    Group {
                        Color.black.opacity(0.05)
                    }
                }
            }
            .frame(width: 48, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: asset.title)

                if let description = asset.description {
                    Text(verbatim: description)
                        .font(.caption)
                }
            }

            Spacer()

            if let typeStr = asset.metaData?.contentType {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(verbatim: typeStr)
                        .font(.footnote)
                }
            }
        }
    }
}

struct AssetItemView_Previews: PreviewProvider {
    static var previews: some View {
        AssetItemView(
            asset: NotificareAsset(
                id: "Asset id",
                title: "Asset title",
                description: "Asset description",
                key: nil,
                url: nil,
                button: nil,
                metaData: nil,
                extra: ["": ""]
            )
        )
    }
}
