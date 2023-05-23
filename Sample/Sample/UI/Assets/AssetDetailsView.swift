//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareAssetsKit
import SwiftUI

struct AssetDetailsView: View {
    let asset: NotificareAsset

    var body: some View {
        List {
            Section {
                AssetDetailsFieldView(key: String(localized: "asset_id"), value: asset.id)
                AssetDetailsFieldView(key: String(localized: "asset_title"), value: asset.title)
                AssetDetailsFieldView(key: String(localized: "asset_title"), value: asset.description)
                AssetDetailsFieldView(key: String(localized: "asset_key"), value: asset.key)
                AssetDetailsFieldView(key: String(localized: "asset_url"), value: asset.url)
                AssetDetailsFieldView(key: String(localized: "asset_button"), value: asset.button?.label)
                AssetDetailsFieldView(key: String(localized: "asset_action"), value: asset.button?.action)

                if let metaData = asset.metaData {
                    AssetDetailsFieldView(key: String(localized: "asset_original_file_name"), value: metaData.originalFileName)
                    AssetDetailsFieldView(key: String(localized: "asset_content_type"), value: metaData.contentType)
                    AssetDetailsFieldView(key: String(localized: "asset_content_length"), value: String(metaData.contentLength))
                } else {
                    AssetDetailsFieldView(key: String(localized: "asset_meta_data"), value: nil)
                }

                if asset.extra.isEmpty {
                    AssetDetailsFieldView(key: String(localized: "asset_extras"), value: nil)
                } else {
                    HStack {
                        Text(String(localized: "asset_extras"))
                            .fontWeight(.bold)
                    }

                    ForEach(asset.extra.keys.sorted(), id: \.self) { key in
                        AssetDetailsFieldView(key: key, value: String(describing: asset.extra[key]))
                    }
                }
            }
        }
        .navigationTitle(String(localized: "assets_details_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AssetDetailsFieldView: View {
    let key: String
    let value: String?

    var body: some View {
        HStack {
            Text(key)
                .padding(.trailing)

            Spacer()

            Text(value ?? "-")
                .lineLimit(1)
                .truncationMode(.head)
                .foregroundColor(Color.gray)
        }
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsView(
            asset: NotificareAsset(
                id: "12345",
                title: "Title",
                description: nil,
                key: nil,
                url: nil,
                button: nil,
                metaData: nil,
                extra: [String: Any]()
            )
        )
    }
}
