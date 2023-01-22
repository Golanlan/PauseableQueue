import Foundation

enum QueueStates: String {
    case pause = "pause"
    case resume = "resume"
}

protocol PauseableQueueProtocol: AnyObject {
    func didPerform(_ state: QueueStates)
}

class PauseableQueue<T> {
    private var pausableDispatchQueue = DispatchQueue(label: "pausableDispatchQueue")
    private var operationsDispatchQueue = DispatchQueue(label: "operationsDispatchQueue")
    private var elements: [T] = []
    private var workItem: DispatchWorkItem?
    private var state: QueueStates = .resume
        
    weak var delegate: PauseableQueueProtocol?
    
    /// Returns the first element of the `elements` array, or `nil` if the array is empty.
    var head: T? {
        return elements.first
    }
    
    /// Returns the last element in the `elements` array, or `nil` if the array is empty.
    var tail: T? {
        return elements.last
    }
        
    /// Appends an item to the elements array and returns a completion closure when done
    ///
    /// - Parameters:
    ///   - value: Generic item to be appended
    ///   - completion: Closure that is called when the operation is completed
    func enqueue(_ value: T, completion: (() -> Void)? = nil) {
        operationsDispatchQueue.sync { [weak self] in
            self?.elements.append(value)
            print("Queue: Element enqueued, Elements on queue: \(self?.elements.count ?? 0)")
            completion?()
        }
    }
    
    /// Dequeuing and returning dequeued item
    ///
    /// Removing 'head' item of elements array, and returing him in completion
    ///
    /// - Parameter completion: completed when item removed from elements array
    func dispatchDequeue(completion: @escaping ((T?) -> Void)) {
        self.workItem = DispatchWorkItem(block: { [weak self] in
            self?.dequeueLogic(completion: completion)
        })
        
        if let workItem = self.workItem {
            self.pausableDispatchQueue.async(execute: workItem)
        }
    }
    
    /// Removes the first item from the elements array without adding a task to the operationsQueue.
    ///
    /// - Parameter completion: Called when the item has been removed from the elements array. The removed item is passed as a parameter.
    func dequeue(completion: ((T?) -> Void)? = nil) {
        self.dequeueLogic(completion: completion)
    }
    
    /// Dequeues the first element from the queue and returns it asynchronously, if there are any elements.
    ///
    /// - Parameters:
    ///   - completion: An optional closure that takes an element of type `T` as a parameter and is called when the element is dequeued. The closure returns `nil` if the queue is empty.
    private func dequeueLogic(completion: ((T?) -> Void)? = nil) {
        operationsDispatchQueue.sync {
            guard !elements.isEmpty else {
                print("Queue: Elements empty")
                completion?(nil)
                return
            }

            let removedItem = elements.removeFirst()
            completion?(removedItem)
            
            print("Queue: Element dequeued, Elements on queue: \(elements.count)")
        }
    }
    
    /// Asynchronously cancels the current item on the operations dispatch queue.
    func cancelItem() {
        operationsDispatchQueue.async { [weak self] in
            self?.workItem?.cancel()
        }
    }
    
    /// Pauses the pausableDispatchQueue and updates the state, if current state is "resume".
    func pause() {
        operationsDispatchQueue.sync { [weak self] in
            if self?.state == .resume {
                self?.pausableDispatchQueue.suspend()
                self?.updateState(.pause)
                
                print("pausableDispatchQueue paused")
            }
        }
    }
    
    /// Resumes paused operations on the pausableDispatchQueue and updates the state to .resume. Also emits the current head value to the headSubject.
    func resume() {
        operationsDispatchQueue.sync { [weak self] in
            if self?.state == .pause {
                self?.pausableDispatchQueue.resume()
                self?.updateState(.resume)
                
                print("pausableDispatchQueue resumed")
            }
        }
    }
    
    /// Updates the queues `state` and notifies the delegate
    private func updateState(_ state: QueueStates) {
        self.state = state
        self.delegate?.didPerform(state)
        
        print("pausableDispatchQueue state: \(state.rawValue)")
    }
    
    /// Returns the queues current `state`
    func getState() -> QueueStates? {
        return state
    }
    
    /// Returns the number of elements currently in the queue
    func count() -> Int {
        return elements.count
    }
    
    /// Removes all elements from the queue
    func clear() {
        operationsDispatchQueue.sync { [weak self] in
            self?.elements.removeAll()
            
            print("Queue: Elements cleared")
        }
    }
}
