import Dispatch

fileprivate let backgroundExecutionQueue = DispatchQueue(label: "org.openkitten.schrodinger.backgroundexecution", attributes: .concurrent)
fileprivate let futureManipulationQueue = DispatchQueue(label: "org.openkitten.schrodinger.futurequeue")

public class Promise<Wrapped> {
    private var result: Wrapped? = nil
    private var error: Swift.Error? = nil
    let semaphore = DispatchSemaphore(value: 0)
    private let timeout: DispatchTime
    
    enum Error : Swift.Error {
        case strangeInconsistency
        case timeout(after: DispatchTime)
    }
    
    func complete(_ closure: (() throws -> Wrapped)) {
        defer { semaphore.signal() }
        
        do {
            result = try closure() //.value(try closure())
        } catch {
            self.error = error
        }
    }
    
    public func await<T>(_ closure: ((Wrapped) throws -> T)) throws -> T {
        guard semaphore.wait(timeout: timeout) == .success else {
            throw Error.timeout(after: timeout)
        }
        
        guard let result = result else {
            throw error ?? Error.strangeInconsistency
        }
        
        return try closure(result)
    }
    
    public func await() throws -> Wrapped {
        return try await { $0 }
    }
    
    public init(timeout: DispatchTimeInterval = .seconds(10), closure: @escaping (() throws -> Wrapped)) {
        self.timeout = DispatchTime.now() + timeout
        
        backgroundExecutionQueue.async {
            self.complete(closure)
        }
    }
}

public func async<T>(timingOut after: DispatchTimeInterval = .seconds(10), _ closure: @escaping (() throws -> T)) -> Promise<T> {
    return Promise<T>(timeout: after, closure: closure)
}
