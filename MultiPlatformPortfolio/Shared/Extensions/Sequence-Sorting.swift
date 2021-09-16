import Foundation

//  `Comparable` : A type that can be compared using the relational operators <, <=, >=, and >.

extension Sequence {
    /// A function that can sort an Array, this function is constrained by `Comparable`
    /// `Element` is generic so an Array of  Car, Boat, Cat etc can sort based on a specific property.
    /// - Example usage: ` .sorted(by: \Item.itemCreationDate)` , `.sorted(by: \Item.itemTitle)`
    ///  - Drawback: it will sort any array based on `<`, what if you want to use `<`, `<=`, `>=`, and `>`?.
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted {
            $0[keyPath: keyPath] < $1[keyPath: keyPath]
        }
    }

    // So to give us more flexibility:

    /// A function that can sort an Array, this function is __not__ constrained by `Comparable`
    /// This function can `throw` but it doesn't have to `throw`. Flexibility! This is possible because of `rethrows`.
    /// `rethrows`  means if `areInIncreasingOrder` is passed a throwing function then this `sorted(by:)`
    /// method also becomes a throwing function
    /// - Example usage: ` .sorted(by: \Item.itemCreationDate, using: >)
    /// - Example usage: ` .sorted(by: \Item.itemCreationDate) { $0 > $1 }
    func sorted<Value>(
                    by keyPath: KeyPath<Element, Value>,
                    using areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    /*:
     With the method above we can clean up the first method we wrote from this:
     
        `self.sorted {
             $0[keyPath: keyPath] < $1[keyPath: keyPath]
         }`
     
     to this:
        self.sorted(by: keyPath, using: < )
     
     */

    // Using 1 sortDescriptor
    func sorted(by sortDescriptor: NSSortDescriptor) -> [Element] {
        self.sorted {
            sortDescriptor.compare($0, to: $1) == .orderedAscending
        }
    }

    // Using multiple

    func sorted(by sortDescriptors: [NSSortDescriptor]) -> [Element] {
        self.sorted {
            for descriptor in sortDescriptors {
                switch descriptor.compare($0, to: $1) {
                case .orderedAscending:
                    return true
                case .orderedDescending:
                    return false
                case .orderedSame:
                    continue
                }
            }

            return false
        }
    }

}
