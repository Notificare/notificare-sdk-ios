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
                AssetDetailsField(key: String(localized: "asset_id"), value: asset.id)
                AssetDetailsField(key: String(localized: "asset_title"), value: asset.title)
                AssetDetailsField(key: String(localized: "asset_title"), value: asset.description)
                AssetDetailsField(key: String(localized: "event_key"), value: asset.key)
                AssetDetailsField(key: String(localized: "asset_url"), value: asset.url)
                AssetDetailsField(key: String(localized: "asset_button"), value: asset.button?.label)
                AssetDetailsField(key: String(localized: "asset_action"), value: asset.button?.action)

                if let metaData = asset.metaData {
                    AssetDetailsField(key: String(localized: "asset_original_file_name"), value: metaData.originalFileName)
                    AssetDetailsField(key: String(localized: "asset_content_type"), value: metaData.contentType)
                    AssetDetailsField(key: String(localized: "asset_content_length"), value: String(metaData.contentLength))
                } else {
                    AssetDetailsField(key: String(localized: "asset_meta_data"), value: "-")
                }

                if asset.extra.isEmpty {
                    AssetDetailsField(key: String(localized: "asset_extras"), value: "-")
                } else {
                    HStack {
                        Text(String(localized: "asset_extras"))
                            .fontWeight(.bold)
                    }

                    ForEach(asset.extra.keys.sorted(), id: \.self) { key in
                        AssetDetailsField(key: key, value: String(describing: asset.extra[key]))
                    }
                }
            }
        }
        .navigationTitle(String(localized: "assets_details_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AssetDetailsField: View {
    let key: String
    let value: String?

    var body: some View {
        HStack {
            Text(key)
                .padding(.trailing)
            Spacer()
            if let value = value {
                Text(value)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundColor(Color.gray)
            } else {
                Text("-")
                    .lineLimit(1)
                    .truncationMode(.head)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsView(asset: NotificareAsset(id: "12345", title: "Title", description: nil, key: nil, url: nil, button: nil, metaData: nil, extra: [String: Any]()))
    }
}
