// Copyright (c) 2020 Notificare. All rights reserved.
//

@testable import NotificareAssetsKit
import Testing

struct NotificareAssetTest {
    @Test
    func testNotificareAssetSerialization() {
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

            assertAsset(asset: asset, convertedAsset: convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testNotificareAssetSerializationWithNilProps() {
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

            assertAsset(asset: asset, convertedAsset: convertedAsset)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testButtonSerialization() {
        let button = NotificareAsset.Button(
            label: "testLabel",
            action: "testAction"
        )

        do {
            let convertedButton = try NotificareAsset.Button.fromJson(json: button.toJson())

            #expect(button.label == convertedButton.label)
            #expect(button.action == convertedButton.action)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testButtonSerializationWithNilProps() {
        let button = NotificareAsset.Button(
            label: nil,
            action: nil
        )

        do {
            let convertedButton = try NotificareAsset.Button.fromJson(json: button.toJson())

            #expect(button.label == convertedButton.label)
            #expect(button.action == convertedButton.action)
        } catch {
            Issue.record()
        }
    }

    @Test
    func testMetaDataSerialization() {
        let metadata = NotificareAsset.MetaData(
            originalFileName: "testOriginalName",
            contentType: "testContentType",
            contentLength: 1
        )

        do {
            let convertedMetadata = try NotificareAsset.MetaData.fromJson(json: metadata.toJson())

            #expect(metadata.originalFileName == convertedMetadata.originalFileName)
            #expect(metadata.contentType == convertedMetadata.contentType)
            #expect(metadata.contentLength == convertedMetadata.contentLength)
        } catch {
            Issue.record()
        }
    }

    func assertAsset(asset: NotificareAsset, convertedAsset: NotificareAsset) {
        #expect(asset.id == convertedAsset.id)
        #expect(asset.title == convertedAsset.title)
        #expect(asset.description == convertedAsset.description)
        #expect(asset.key == convertedAsset.key)
        #expect(asset.url == convertedAsset.url)
        #expect(asset.button?.label == convertedAsset.button?.label)
        #expect(asset.button?.action == convertedAsset.button?.action)
        #expect(asset.metaData?.originalFileName == convertedAsset.metaData?.originalFileName)
        #expect(asset.metaData?.contentType == convertedAsset.metaData?.contentType)
        #expect(asset.metaData?.contentLength == convertedAsset.metaData?.contentLength)
        #expect(NSDictionary(dictionary: asset.extra) ==  NSDictionary(dictionary: convertedAsset.extra))

    }
}
