import Dispatch

fileprivate let backgroundExecutionQueue = DispatchQueue(label: "org.openkitten.schrodinger.backgroundexecution", attributes: .concurrent)
fileprivate let futureManipulationQueue = DispatchQueue(label: "org.openkitten.schrodinger.futurequeue")

public class ManualPromise<Wrapped> {
    var result: Wrapped? = nil
    var error: Swift.Error? = nil
    let semaphore = DispatchSemaphore(value: 0)
    let timeout: DispatchTime
    
    public enum Error : Swift.Error {
        case strangeInconsistency
        case alreadyCompleted
        case timeout(after: DispatchTime)
    }
    
    public init(timeout: DispatchTimeInterval = .seconds(10)) {
        self.timeout = DispatchTime.now() + timeout
    }
    
    public func complete(_ value: Wrapped) throws {
        if result != nil || error != nil {
            error = Error.alreadyCompleted
            return
        }
        
        self.result = value
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
        guard semaphore.wait(timeout: timeout) == .success else {
            throw Error.timeout(after: timeout)
        }
        
        guard let result = result else {
            throw error ?? Error.strangeInconsistency
        }
        
        return result
    }
}

public class Promise<Wrapped> : ManualPromise<Wrapped> {
    
    
    func complete(_ closure: (() throws -> Wrapped)) {
        defer { semaphore.signal() }
        
        do {
            if result != nil || error != nil {
                error = Error.alreadyCompleted
                return
            }
            
            result = try closure() //.value(try closure())
        } catch {
            self.error = error
        }
    }
    
    public init(timeout: DispatchTimeInterval = .seconds(10), closure: @escaping (() throws -> Wrapped)) {
        super.init(timeout: timeout)
        
        backgroundExecutionQueue.async {
            self.complete(closure)
        }
    }
}

public func async<T>(timingOut after: DispatchTimeInterval = .seconds(10), _ closure: @escaping (() throws -> T)) -> Promise<T> {
    return Promise<T>(timeout: after, closure: closure)
}
