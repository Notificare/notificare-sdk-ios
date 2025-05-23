import Foundation
import Testing

internal struct InsertSortedTests {
    @Test
    internal func insertIntoEmptyArray() {
        var array: [Int] = []
        let index = array.insertSorted(5, by: <)
        #expect(array == [5])
        #expect(index == 0)
    }

    @Test
    internal func insertAtBeginning() {
        var array = [10, 20, 30]
        let index = array.insertSorted(5, by: <)
        #expect(array == [5, 10, 20, 30])
        #expect(index == 0)
    }

    @Test
    internal func insertInMiddle() {
        var array = [10, 20, 30]
        let index = array.insertSorted(25, by: <)
        #expect(array == [10, 20, 25, 30])
        #expect(index == 2)
    }

    @Test
    internal func insertAtEnd() {
        var array = [10, 20, 30]
        let index = array.insertSorted(40, by: <)
        #expect(array == [10, 20, 30, 40])
        #expect(index == 3)
    }

    @Test
    internal func insertWithCustomComparator() {
        struct Person {
            let name: String
            let age: Int
        }

        var people = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 40),
        ]

        let newPerson = Person(name: "Charlie", age: 35)
        let index = people.insertSorted(newPerson) { $0.age < $1.age }

        #expect(people[1].name == "Charlie")
        #expect(index == 1)
    }
}
