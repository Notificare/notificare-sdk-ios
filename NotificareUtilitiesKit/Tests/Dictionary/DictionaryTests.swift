//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Testing

internal struct DictionaryExtensionsTests {

    @Test
    internal func testMapKeysWithBasicTransformation() throws {
        let originalDictionary = ["one": 1, "two": 2, "three": 3]

        let transformedDictionary = originalDictionary.mapKeys { key in
            "key_" + key
        }

        #expect(transformedDictionary["key_one"] == 1)
        #expect(transformedDictionary["key_two"] == 2)
        #expect(transformedDictionary["key_three"] == 3)
    }

    @Test
    internal func testMapKeysWithDifferentTypes() throws {
        let originalDictionary = ["apple": 1, "banana": 2]

        let transformedDictionary = originalDictionary.mapKeys { key in
            key.count
        }

        #expect(transformedDictionary[5] == 1)
        #expect(transformedDictionary[6] == 2)
    }
}
