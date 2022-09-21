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


example(
    of: "FlatMap",
    comment: """
FlatMap operator flatten multiple upstream publishers into single downstream publisher that you can subscribe to it.
So you can have a publisher that emits a value and you want to flatMap the publisher it self into something else, i.e into another publisher.
So imagine you have a publisher of <String, Never> and you want to flatMap into <Int, Never>
or even <String, Never> => <String, Never> but doing different logic like the following example.
""") {
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        Just(
            codes
                .compactMap{ code in
                    guard (32...128144).contains(code) else { return nil }
                    return String(UnicodeScalar(code) ?? " ")
                }
                .joined()
        )
        .eraseToAnyPublisher()
    }
    
    [128144, 32, 72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33, 32, 128144]
        .publisher
        .collect()
        .flatMap(decode)
        .sink(receiveCompletion: { print($0)},
              receiveValue: { print($0)})
        .store(in: &subscriptions)
}

example(
    of: "Flat map 2",
    comment:"""
With FlatMap Operator you can chain the upstream operators one after another, and return one publisher which will publish to the down stream.
Each upstream publisher input should be the output from the pervious publisher.
""") {
    
    func oddOrEven(_ numbers: [Int]) -> AnyPublisher<[Bool], Never> {
        Just (
            numbers.compactMap { $0.isMultiple(of:2) }
        ).eraseToAnyPublisher()
    }
    
    func formatNumbers(_ numbers: [Bool]) -> AnyPublisher<String, Never> {
        Just (
            numbers
                .map { return $0 == true ? "Even" : "Odd" }
                .joined(separator: ", ")
        ).eraseToAnyPublisher()
    }
    
    func upperCase(_ string: String) -> AnyPublisher<String, Never> {
        Just(
            string.uppercased()
        ).eraseToAnyPublisher()
    }
    
    [1, 3, 18, 19, 500]
        .publisher
        .collect()
        .flatMap(oddOrEven)
        .flatMap(formatNumbers)
        .flatMap(upperCase)
        .sink(receiveValue: { print($0) } )
        .store(in: &subscriptions)
}

example(of: "replaceNil") {
    ["A", nil, "B"]
        .publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "-")
        .sink(receiveValue: { print($0) } )
        .store(in: &subscriptions)
}

example(of: "Empty Publisher",
        comment: """
There is new publisher type called Empty which is empty 🤷‍♂️, i.e Publisher that won't send anything
"""
) {
    let empty = Empty<Int, Never>()
    empty
        .sink(receiveCompletion: { print($0) },
              receiveValue: { $0 } )
        .store(in: &subscriptions)
}

example(of: "Replace Empty") {
    let empty = Empty<Int, Never>()
    empty
        .replaceEmpty(with: 5)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) } )
        .store(in: &subscriptions)
    
}

example(of: "Scan") {
    var randomGenerator: Int { Int.random(in: -10...10) }
    func random(_ number: Int) -> Int { randomGenerator }
    let workingDaysValues = (0...25).map(random)
    workingDaysValues
        .publisher
        .scan(50) { current, latest in
            max(0, current + latest)
        }
        .sink { _ in }
        .store(in: &subscriptions)
}
