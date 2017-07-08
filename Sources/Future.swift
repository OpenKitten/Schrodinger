import Dispatch

public class Future<T> {
    var result: Result?
    var handlers = [ResultHandler]()
    var semaphores = [DispatchSemaphore]()
    let start = DispatchTime.now()
    
    public typealias ResultHandler = ((Result) -> ())
    
    /// A result, be it an error or successful result
    public enum Result {
        case success(T)
        case error(Swift.Error)
        
        public func assertSuccess() throws -> T {
            switch self {
            case .success(let data):
                return data
            case .error(let error):
                throw error
            }
        }
    }
    
    /// Awaits for a `Result`
    ///
    /// The result can be an error or successful data. May not throw.
    ///
    /// Usage:
    ///
    /// ```swift
    /// let future = Future<User>
    ///
    /// future.then { result in
    ///     switch {
    ///     case .success(let user):
    ///         user.doStuff()
    ///     case .error(let error):
    ///         print(error)
    ///     }
    /// }
    /// ```
    public func then(_ handler: @escaping ResultHandler) {
        futureManipulationQueue.sync {
            if let result = result {
                handler(result)
            } else {
                handlers.append(handler)
            }
        }
    }
    
    /// Gets called only when a result has been successfully captured
    ///
    /// ```swift
    /// future.onSuccess { data in
    ///     process(data)
    /// }
    /// ```
    public func onSuccess(_ handler: @escaping ((T) -> ())) {
        self.then { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
    }
    
    public func await(until interval: DispatchTimeInterval) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        
        futureManipulationQueue.sync {
            self.semaphores.append(semaphore)
        }
        
        guard semaphore.wait(timeout: DispatchTime.now() + interval) == .success else {
            throw FutureError.timeout(after: interval)
        }
        
        guard let result = result else {
            throw FutureError.inconsistency
        }
        
        return try result.assertSuccess()
    }
    
    /// Gets called only when an error occurred due to throwing
    ///
    /// ```swift
    /// future.onError { error in
    ///     print(error)
    /// }
    /// ```
    public func onError(_ handler: @escaping ((Swift.Error) -> ())) {
        self.then { result in
            if case .error(let error) = result {
                handler(error)
            }
        }
    }
    
    /// Completes the future, calling all awaiting handlers
    ///
    /// If the completion throws an error, this will be passed to the handlers
    public func complete(_ closure: @escaping () throws -> T) throws {
        try futureManipulationQueue.sync {
            guard result == nil else {
                throw FutureError.alreadyCompleted
            }
        }
        
        self._complete(closure)
    }
    
    internal func _complete(_ closure: @escaping () throws -> T) {
        backgroundExecutionQueue.async {
            do {
                let result = Result.success(try closure())
                
                futureManipulationQueue.sync {
                    for handler in self.handlers {
                        handler(result)
                    }
                }
            } catch {
                futureManipulationQueue.sync {
                    let error = Result.error(error)
                    
                    for handler in self.handlers {
                        handler(error)
                    }
                }
            }
        }
    }
    
    public var isCompleted: Bool {
        return futureManipulationQueue.sync { self.result != nil }
    }
    
    public func map<B>(_ closure: @escaping ((T) throws -> (B))) throws -> Future<B> {
        return try Future<B>(transform: closure, from: self)
    }
    
    public init() {}
    
    public init(_ closure: @escaping () throws -> T) {
        self._complete(closure)
    }
    
    internal init<Base>(transform: @escaping ((Base) throws -> (T)), from: Future<Base>) throws {
        try futureManipulationQueue.sync {
            if let result = from.result {
                switch result {
                case .success(let data):
                    self.result = .success(try transform(data))
                case .error(let error):
                    self.result = .error(error)
                }
            } else {
                from.then { result in
                    switch result {
                    case .success(let data):
                        do {
                            self.result = .success(try transform(data))
                        } catch {
                            self.result = .error(error)
                        }
                    case .error(let error):
                        self.result = .error(error)
                    }
                }
            }
        }
    }
}

public enum FutureError : Error {
    case alreadyCompleted
    case timeout(after: DispatchTimeInterval)
    case inconsistency
}
