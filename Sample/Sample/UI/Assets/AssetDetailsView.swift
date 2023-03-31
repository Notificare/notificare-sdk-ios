//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import NotificareAssetsKit

struct AssetDetailsView: View {
    var asset: NotificareAsset
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(String(localized: "asset_id"))
                        .padding(.trailing)
                    Spacer()
                    Text(asset.id)
                }
                
                HStack {
                    Text(String(localized: "asset_title"))
                        .padding(.trailing)
                    Spacer()
                    Text(asset.title)
                }
                
                HStack {
                    Text(String(localized: "asset_description"))
                        .padding(.trailing)
                    Spacer()
                    
                    if let description = asset.description {
                        Text(description)
                    } else {
                        Text("-")
                    }
                }
                
                HStack {
                    Text(String(localized: "event_key"))
                        .padding(.trailing)
                    Spacer()
                    
                    if let key = asset.key {
                        Text(key)
                    } else {
                        Text("-")
                    }
                }
                
                HStack {
                    Text(String(localized: "asset_url"))
                        .padding(.trailing)
                    Spacer()
                    
                    if let url = asset.url {
                        Text(url)
                    } else {
                        Text("-")
                    }
                }
                
                if let label = asset.button?.label {
                    HStack {
                        Text(String(localized: "asset_button"))
                        Spacer()
                        Text(label)
                    }
                } else {
                    HStack {
                        Text(String(localized: "asset_button"))
                            .padding(.trailing)
                        Spacer()
                        Text("-")
                    }
                }
                
                if let action = asset.button?.action {
                    HStack {
                        Text(String(localized: "asset_action"))
                            .padding(.trailing)
                        Spacer()
                        Text(action)
                    }
                }
                
                if let metaData = asset.metaData {
                    HStack {
                        Text(String(localized: "asset_original_file_name"))
                            .padding(.trailing)
                        Spacer()
                        Text(metaData.originalFileName)
                    }
                    
                    HStack {
                        Text(String(localized: "asset_content_type"))
                            .padding(.trailing)
                        Spacer()
                        Text(metaData.contentType)
                    }
                    
                    HStack {
                        Text(String(localized: "asset_content_length"))
                            .padding(.trailing)
                        Spacer()
                        Text(String(metaData.contentLength))
                    }
                } else {
                    HStack {
                        Text(String(localized: "asset_meta_data"))
                            .padding(.trailing)
                        Spacer()
                        Text("-")
                    }
                }
                
                if asset.extra.isEmpty {
                    HStack {
                        Text(String(localized: "asset_extras"))
                        Spacer()
                        Text("-")
                    }
                } else {
                    HStack {
                        Text(String(localized: "asset_extras"))
                            .fontWeight(.bold)
                    }
                    
                    ForEach(asset.extra.keys.sorted(), id: \.self) { key in
                        HStack {
                            Text(key)
                                .padding(.trailing)
                            Spacer()
                            Text(String(describing: asset.extra[key]))
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "assets_details_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsView(asset: NotificareAsset(id: "12345", title: "Title", description: nil, key: nil, url: nil, button: nil, metaData: nil, extra: [String:Any]()))
    }
}
