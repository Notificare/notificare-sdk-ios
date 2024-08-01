//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareAssetsKit
import Testing

struct AssetsPushAPIModelsTest {
    @Test
    func testAssetToModel() {
        let expectedAsset = NotificareAsset(
            id: "testId",
            title: "testTitle",
            description: "testDescription",
            key: "testKey",
            url: nil,
            button: NotificareAsset.Button(
                label: "testLabel",
                action: "testAction"
            ),
            metaData: NotificareAsset.MetaData(
                originalFileName: "testOriginalName",
                contentType: "testContentType",
                contentLength: 1
            ),
            extra: ["testExtraKey": "testExtraValue"]
        )

        let asset = NotificareInternals.PushAPI.Models.Asset(
            _id: "testId",
            key: "testKey",
            title: "testTitle",
            description: "testDescription",
            extra: ["testExtraKey": "testExtraValue"],
            button: NotificareInternals.PushAPI.Models.Asset.Button(
                label: "testLabel",
                action: "testAction"
            ),
            metaData: NotificareInternals.PushAPI.Models.Asset.MetaData(
                originalFileName: "testOriginalName",
                contentType: "testContentType",
                contentLength: 1
            )
        ).toModel()

        assertAsset(expectedAsset: expectedAsset, asset: asset)
    }

    @Test
    func testAssetWithNilPropsToModel() {
        let expectedAsset = NotificareAsset(
            id: "testId",
            title: "testTitle",
            description: nil,
            key: nil,
            url: nil,
            button: nil,
            metaData: nil,
            extra: [:]
        )

        let asset = NotificareInternals.PushAPI.Models.Asset(
            _id: "testId",
            key: nil,
            title: "testTitle",
            description: nil,
            extra: [:],
            button: nil,
            metaData: nil
        ).toModel()

        assertAsset(expectedAsset: expectedAsset, asset: asset)
    }

    func assertAsset(expectedAsset: NotificareAsset, asset: NotificareAsset) {
        #expect(expectedAsset.id == asset.id)
        #expect(expectedAsset.title == asset.title)
        #expect(expectedAsset.description == asset.description)
        #expect(expectedAsset.key == asset.key)
        #expect(expectedAsset.url == asset.url)
        #expect(expectedAsset.button?.label == asset.button?.label)
        #expect(expectedAsset.button?.action == asset.button?.action)
        #expect(expectedAsset.metaData?.originalFileName == asset.metaData?.originalFileName)
        #expect(expectedAsset.metaData?.contentType == asset.metaData?.contentType)
        #expect(expectedAsset.metaData?.contentLength == asset.metaData?.contentLength)
        #expect(NSDictionary(dictionary: expectedAsset.extra) ==  NSDictionary(dictionary: asset.extra))

    }
}
