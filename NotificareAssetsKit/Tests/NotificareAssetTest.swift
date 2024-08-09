// Copyright (c) 2020 Notificare. All rights reserved.
//

@testable import NotificareAssetsKit
import Testing

internal struct NotificareAssetTest {
    @Test
    internal func testNotificareAssetSerialization() {
        let asset = NotificareAsset(
            id: "testId",
            title: "testTitle",
            description: "testDescription",
            key: "testKey",
            url: "testUrl",
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

        do {
            let convertedAsset = try NotificareAsset.fromJson(json: asset.toJson())

            #expect(asset == convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testNotificareAssetSerializationWithNilProps() {
        let asset = NotificareAsset(
            id: "testId",
            title: "testTitle",
            description: nil,
            key: nil,
            url: nil,
            button: nil,
            metaData: nil,
            extra: [:]
        )

        do {
            let convertedAsset = try NotificareAsset.fromJson(json: asset.toJson())

            #expect(asset == convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testButtonSerialization() {
        let button = NotificareAsset.Button(
            label: "testLabel",
            action: "testAction"
        )

        do {
            let convertedButton = try NotificareAsset.Button.fromJson(json: button.toJson())

            #expect(button == convertedButton)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testButtonSerializationWithNilProps() {
        let button = NotificareAsset.Button(
            label: nil,
            action: nil
        )

        do {
            let convertedButton = try NotificareAsset.Button.fromJson(json: button.toJson())

            #expect(button == convertedButton)
        } catch {
            Issue.record()
        }
    }

    @Test
    internal func testMetaDataSerialization() {
        let metadata = NotificareAsset.MetaData(
            originalFileName: "testOriginalName",
            contentType: "testContentType",
            contentLength: 1
        )

        do {
            let convertedMetadata = try NotificareAsset.MetaData.fromJson(json: metadata.toJson())

            #expect(metadata == convertedMetadata)
        } catch {
            Issue.record()
        }
    }
}
