import Foundation
import UIKit
import Combine
import _Concurrency

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default

    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification received!")
        }

    center.post(name: myNotification, object: nil)
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification,object: nil)

    // Subscription to Notification Center's Publisher for specific notification.
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
        }

    center.post(name: myNotification, object: nil)

    subscription.cancel()
}

example(of: "Just") {

    let just = Just("Hi")

    _ = just
        .sink(
            receiveCompletion: {
                print("Received completion" , $0)
            }, receiveValue: {
                print("Received value" , $0)
            })

    _ = just
        .sink(
            receiveCompletion: {
                print("Received Another Completion: " , $0) },
            receiveValue: {
                print("Received Another Value: ", $0)
            })
}

example(of: "assign(to:on)") {
    // assign:to:on assigns the published values into a KVO compliant value.
    // published.assign(to: \.name, on: studentObject)
    class Student {
        var name: String = "" {
            didSet {
                print(name)
            }
        }
    }
    let aStudent = Student()

    let publisher = [ "Welcome", "To", "Combine"].publisher

    _ = publisher.assign(to: \.name, on: aStudent)
}

example(of: "assign(to)") {
    // assign(to) always comes with @Published keyword.
    // @Published is used to republish values
    class Fruit {
        @Published var name: String = ""
    }
    let apple = Fruit()

    apple.$name.sink { name in
        print(name)
    }

    (0...3).map(String.init).publisher.assign(to: &apple.$name)
}

example(of: "assign(to) 🎬") {
    class Dude {
        @Published var name: String = ""
    }
    let theDude = Dude()
    theDude.$name.sink(receiveValue: { print($0) })
    Just("Hi").assign(to: &theDude.$name)
}

example(of: "Custom Publisher") {
    let publisher = (0...6).publisher

    class IntSubscriber: Subscriber {
        typealias Input = Int

        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("received value \(input)")
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("received completion")
        }
    }
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

example(of: "Future") {
    var cancelable = [AnyCancellable]()

    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        return Future { promise in
            print("Original")
            DispatchQueue.global().async {
                promise(.success(integer+1))
            }
        }
    }

    let future = futureIncrement(integer: 3, afterDelay: 1.0)
    future
        .sink(receiveCompletion: { print("Received completion: \($0)")},
              receiveValue: { print("Received value: \($0)")})
        .store(in: &cancelable)

    future
        .sink(receiveCompletion: { print("Received second completion: \($0)")},
              receiveValue: { print("Received second value: \($0)")})
        .store(in: &cancelable)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification,object: nil)

    // Subscription to Notification Center's Publisher for specific notification.
    let subscription = publisher
        .sink { _ in
            print("Notification received from a publisher!")
        }

    center.post(name: myNotification, object: nil)

    subscription.cancel()
}

example(of: "Just") {

    let just = Just("Hi")

    _ = just
        .sink(
            receiveCompletion: {
                print("Received completion" , $0)
            }, receiveValue: {
                print("Received value" , $0)
            })

    _ = just
        .sink(
            receiveCompletion: {
                print("Received Another Completion: " , $0) },
            receiveValue: {
                print("Received Another Value: ", $0)
            })
}

example(of: "assign(to:on)") {
    // assign:to:on assigns the published values into a KVO compliant value.
    // published.assign(to: \.name, on: studentObject)
    class Student {
        var name: String = "" {
            didSet {
                print(name)
            }
        }
    }
    let aStudent = Student()

    let publisher = [ "Welcome", "To", "Combine"].publisher

    _ = publisher.assign(to: \.name, on: aStudent)
}

example(of: "assign(to)") {
    // assign(to) always comes with @Published keyword.
    // @Published is used to republish values
    class Fruit {
        @Published var name: String = ""
    }
    let apple = Fruit()

    apple.$name.sink { name in
        print(name)
    }

    (0...3).map(String.init).publisher.assign(to: &apple.$name)
}

example(of: "assign(to) 🎬") {
    class Dude {
        @Published var name: String = ""
    }
    let theDude = Dude()
    theDude.$name.sink(receiveValue: { print($0) })
    Just("Hi").assign(to: &theDude.$name)
}

example(of: "Custom Publisher") {
    let publisher = (0...6).publisher

    class IntSubscriber: Subscriber {
        typealias Input = Int

        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("received value \(input)")
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("received completion")
        }
    }
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

example(of: "Future") {
    // Future is Greedy, because it executes without waiting for subscribers.
    // Future is Smart, because it doesn't re-run, it just replays the values.
    var cancelable = [AnyCancellable]()

    let someFuture: Future<Int,Never> = Future { promise in
        print("Future doesn't wait for subscribers")
        return promise(.success(5))
    }

    someFuture
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &cancelable)

    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        return Future { promise in
            print("Original")
            DispatchQueue.global().async {
                promise(.success(integer+1))
            }
        }
    }

    let future = futureIncrement(integer: 3, afterDelay: 1.0)
    future
        .sink(receiveCompletion: { print("Received completion: \($0)")},
              receiveValue: { print("Received value: \($0)")})
        .store(in: &cancelable)

    future
        .sink(receiveCompletion: { print("Received second completion: \($0)")},
              receiveValue: { print("Received second value: \($0)")})
        .store(in: &cancelable)
}

example(of: "PassThroughSubject") {
    enum MyError: Error {
        case dummy
    }

    class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError

        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        func receive(_ input: String) -> Subscribers.Demand {
            print("received value: \(input)")
            return input == "++" ? .max(1) : .none
        }
        func receive(completion: Subscribers.Completion<MyError>) {
            print("received completion")
        }
    }

    let subject = PassthroughSubject<String, MyError>()
    let stringSubscriber = StringSubscriber()

    subject.subscribe(stringSubscriber) // The autopilot mode based on the manual

    let subscription = subject
        .print()
        .sink(
            receiveCompletion: { print("receive completion (Sink): \($0)")},
            receiveValue: { print("receive value (Sink): \($0)")})

    subject.send("try1")
    subject.send("try2")
    subject.send("++")
    subject.send("try3")
    subject.send("++")
    subject.send("try4")
    subject.send("try5")
    subscription.cancel()
    subject.send("try6")
    subject.send(completion: .finished)
    subject.send("try7")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()

    let subject = CurrentValueSubject<Int, Never>(0)

    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    subject
        .print() // logs all publishing events to the console.
        .sink(receiveValue: { print("Second Subscription \($0)") })
        .store(in: &subscriptions)

    subject.send(1)
    subject.send(2)
    subject.value = 3

    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("received input: \(input)")
            switch input {
            case 1: return .max(2)
            case 3: return .max(1)
            default: return .none
            }
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("received completion \(completion)")
        }
    }
    let subject = CurrentValueSubject<Int, Never>(1)
    let subscriber = IntSubscriber()
    subject.subscribe(subscriber)
    subject.send(2)
    subject.value = 3
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type eraser") {
    let subject = PassthroughSubject<Int, Never>()
    let publisher = subject.eraseToAnyPublisher()

    publisher
        .sink(receiveValue: { print($0) })

    subject.send(1)

    // ⛔️ let imagePublisher = Publisher<Int, Never>() ⛔️
    let imageSubject = PassthroughSubject<UIImage, Never>()
    let imagePublisher = imageSubject.eraseToAnyPublisher()

    imagePublisher
        .sink(receiveValue: { print($0) })
    imageSubject.send(.init())
}
