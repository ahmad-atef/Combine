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

example(of: "dropFirst") {
    let numbers = (1...10).publisher
    
    numbers
        .dropFirst(8)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "dropWhile",
        detailedDescription: """
dropWhile keeps dropping as the condition is true, the moment the condition becomes false then the publisher stops dropping and send through all the values...
"""
) {
    let numbers = (1...10).publisher
    
    numbers
        .drop(while: { $0 % 5 != 0 } )
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "dropUntilOutputFrom") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0)})
        .store(in: &subscriptions)
    
    taps.send(1)
    taps.send(3)
    taps.send(4)
    
    isReady.send()
    taps.send(10)
    taps.send(11)
}

example(of: "Prefix()") {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(2)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)})
        .store(in: &subscriptions)
}

example(of: "Prefix(while)",
        detailedDescription:
"""
prefix(while) start prefixing as long the condition is valid, the moment the condition becomes false, the prefixing operation
stops and the publisher completes
"""
) {
    let numbers = (1...10).publisher
    
    numbers
        .prefix(while: { $0 < 5 })
        .sink(receiveValue: { print($0)})
        .store(in: &subscriptions)
}

example(of: "prefixUntilOutputFrom") {
    let numbers = PassthroughSubject<Int, Never>()
    let isReady = PassthroughSubject<Void, Never>()
    
    numbers
        .prefix(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    
    isReady.send()
    numbers.send(4)
}

example(of: "challenge") {
    let numbers = (1...100).publisher
    
    numbers
        .dropFirst(50)
        .prefix(20)
        .filter { $0 % 2 == 0 }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
