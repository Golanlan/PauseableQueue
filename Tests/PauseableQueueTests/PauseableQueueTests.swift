import XCTest
@testable import PauseableQueue

class PauseableQueueTests: XCTestCase {
    var queue: PauseableQueue<Int>!

    override func setUp() {
        queue = PauseableQueue<Int>()
    }

    func testEnqueue() {
        queue.enqueue(1)
        XCTAssertEqual(queue.head, 1)
        XCTAssertEqual(queue.tail, 1)
    }

    func testDequeue() {
        queue.enqueue(1)
        queue.enqueue(2)

        queue.dequeue { (item) in
            XCTAssertEqual(item, 1)
        }
        XCTAssertEqual(queue.head, 2)
        XCTAssertEqual(queue.tail, 2)
    }

    func testDequeueEmpty() {
        queue.dequeue { (item) in
            XCTAssertNil(item)
        }
    }

    func testPauseResume() {
        queue.enqueue(1)
        queue.enqueue(2)

        queue.pause()

        queue.dequeue { (item) in
            XCTAssertEqual(item, 1)
        }

        queue.resume()

        queue.dequeue { (item) in
            XCTAssertEqual(item, 2)
        }
    }


    func testCancelItem() {
        queue.enqueue(1)
        queue.enqueue(2)

        queue.dispatchDequeue { (item) in
            XCTAssertEqual(item, 1)
        }

        queue.cancelItem()

        queue.dispatchDequeue { (item) in
            XCTAssertNil(item)
        }
    }
}
