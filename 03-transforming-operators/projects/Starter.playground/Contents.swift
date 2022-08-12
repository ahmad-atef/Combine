import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: Collect
example(of: "Collect",
        comment: "waits till the upstream publisher completes, and then collect all published values and send it in a single array to the downstram") {
    ["A", "B", "C", "D"].publisher
        .collect()
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// MARK: Collect with Limit
example(of: "Collect(count)",
        comment: "collects the values with the count number you pass, meaning that this operator will wait for the upstream publisher till it finishes and then send the values into the downstream into baches of the count you specifiy") {
    ["A", "B", "C", "D"].publisher
        .collect(2)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)})
        .store(in: &subscriptions)
}

// MARK: Map
example(of: "map") {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = .init(languageComponents: .init(language: .init(identifier: "ar")))
    numberFormatter.numberStyle = .spellOut
    
    [123, 4, 56].publisher
        .map { numberFormatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // In this block, notice how:
    // - The NumberFormatter can take different local / language and how the formatter got string from NSNumber Integer
    // - How the ouptut become non-optional when adding the default value ?? ""
}

example(of: "Map key path") {
    let publisher = PassthroughSubject<Coordinate, Never>()
    
    publisher
        .map(\.x, \.y)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { x, y in
            print(quadrantOf(x: x, y: y))
        })
        .store(in: &subscriptions)
    
    publisher.send(.init(x: 2, y: 2))
    publisher.send(.init(x: 2, y: -2))
    publisher.send(.init(x: -2, y: 2))
    publisher.send(.init(x: -2, y: -2))
 
    let triplePublisher = PassthroughSubject<Tripple, Never>()
    
    triplePublisher
        .map(\.age, \.sex, \.name)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { age, sex, name in
            print(whatIsYourAge(name: name, age: age, sex: sex))
        })
        .store(in: &subscriptions)
    
    triplePublisher.send(.init(age: 31, name: "Ahmed", sex: .male))
    triplePublisher.send(.init(age: 30, name: "Rana", sex: .female))
    
}
example(of: "Try Map",
        comment:"""
Notice in the `tryMap` operator
1. You have to use the try inside the tryMap operator.
2. The failure comes in thee completion branch.
3. You can build another example, something that can fail, and on fail you will see the failure when using tryMap
""") {
    Just("Directory that doesn't exist")
        .tryMap{ try
            FileManager.default.contentsOfDirectory(atPath: $0)
        }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0)} )
        .store(in: &subscriptions)
}
