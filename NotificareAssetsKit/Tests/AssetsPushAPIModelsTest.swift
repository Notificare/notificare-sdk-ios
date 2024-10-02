//
// Copyright (c) 2024 Notificare. All rights reserved.
//

@testable import NotificareKit
@testable import NotificareAssetsKit
import Testing

internal struct AssetsPushAPIModelsTest {
    @Test
    internal func testAssetToModel() {
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

        #expect(expectedAsset == asset)
    }

    @Test
    internal func testAssetWithNilPropsToModel() {
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

        #expect(expectedAsset == asset)
    }
}
