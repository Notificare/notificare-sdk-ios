import Foundation

extension Array {

    @discardableResult
    public mutating func insertSorted(
        _ element: Element,
        by areInIncreasingOrder: (_ lhs: Element, _ rhs: Element) -> Bool
    ) -> Int {
        let index = firstIndex(where: { areInIncreasingOrder(element, $0) }) ?? count
        insert(element, at: index)

        return index
    }
}
