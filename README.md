# PauseableQueue

A lightweight, generic Swift library that provides a thread-safe, pauseable queue implementation. It allows you to enqueue and dequeue elements in a queue, as well as pause and resume the queue's operations. The library also provides a protocol for delegating queue state changes, making it easy to integrate with your existing codebase. 

## Features

- Thread-safe enqueue and dequeue operations
- Pause and resume queue operations
- Delegation of queue state changes
- Generic element support

## Installation

You can use [Swift Package Manager](https://swift.org/package-manager/) to install `PauseableQueue` by adding the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Golanlan/PauseableQueue", from: "1.0.0")
]
```

## Usage

Here is a basic example of how to use `PauseableQueue` in your code:

```swift
import PauseableQueue

let queue = PauseableQueue<Int>()
queue.enqueue(1)
queue.enqueue(2)
queue.enqueue(3)

queue.dispatchDequeue { (item) in
    if let item = item {
        print(item) // 1
    }
}

queue.dispatchDequeue { (item) in
    if let item = item {
        print(item) // 2
    }
}

queue.pause()
queue.enqueue(4) // This will not be dequeued until the queue is resumed

queue.resume()
queue.dispatchDequeue { (item) in
    if let item = item {
        print(item) // 4
    }
}
```

## Delegation

You can use the PauseableQueueProtocol to receive notifications when the queue state changes:
```swift
class MyClass: PauseableQueueProtocol {
    func didPerform(_ state: QueueStates) {
        switch state {
        case .pause:
            print("Queue paused")
        case .resume:
            print("Queue resumed")
        }
    }
}

let queue = PauseableQueue<Int>()
queue.delegate = MyClass()
queue.pause() // Prints "Queue paused"
```

## Contributing
We welcome contributions to `PauseableQueue`! If you find a bug or have an idea for a new feature, please open an issue or submit a pull request.

When submitting a pull request, please make sure to follow the guidelines below:
- Follow the existing code style
- Write tests for new features and bug fixes
- Update the documentation if necessary
- Keep the pull request small and focused on a single issue

## License
`PauseableQueue` is released under the MIT license. See [LICENSE](LICENSE) for more information.
