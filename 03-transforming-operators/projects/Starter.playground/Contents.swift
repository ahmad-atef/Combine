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
