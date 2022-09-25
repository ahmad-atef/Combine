import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Filter") {
    (1...100)
        .publisher
        .filter({ $0.isMultiple(of: 3)})
        .sink(receiveValue: { n in
            print("\(n) is Multiple of 3!")
        })
        .store(in: &subscriptions)
}

example(of: "remove duplicates") {
    ["a", "b", "c", "a"]
        .publisher
        .removeDuplicates()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    "hey hey hey"
        .components(separatedBy: " ")
        .publisher
        .removeDuplicates()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "Drop and Prefix") {
    let names = ["Ahmed Atef", "Ahmed Gamal","Mo Sharaf","Mo Gamal", "Ahmed Kamal"]
    let prefixed = names.prefix { $0.hasPrefix("Ahmed") }
    
    print(prefixed)
    
    let dropped = names.drop { $0.hasPrefix("Ahmed") }
    print(dropped)
    
    let numbers = [2, 4, 6, 1, 8]
    let prefixedNumbers = numbers.prefix { $0.isMultiple(of: 2) }
    let droppedNumbers = numbers.drop { $0.isMultiple(of: 2) }
    print(prefixedNumbers)
    print(droppedNumbers)
}

example(of: "CompactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    strings
        .compactMap (Float.init)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
    // here we don't care about the values at all, we ignore the output.
    // ignore everything, tell me when you finish.
    let numbers = (1...10_000).publisher
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "first(where)") {
    let numbers = (1...9).publisher
    numbers
        .print("numbers")
        .first(where: { $0.isMultiple(of: 2) } )
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
example(of: "last(where)") {
    let numbers = (1...9).publisher
    numbers
        .print("📡")
        .last(where: { $0.isMultiple(of: 2)})
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "last(where)",
        detailedDescription: "the last(where) operator will not work, until the publisher complete the work") {
    let subject = PassthroughSubject<Int, Never>()
    
    subject
        .print()
        .first(where: { $0.isMultiple(of: 2)})
        .last(where: { $0.isMultiple(of: 3) })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(2)
    subject.send(3)
    
    subject.send(completion: .finished)
}
