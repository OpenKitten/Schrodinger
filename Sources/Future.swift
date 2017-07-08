import Dispatch

public class Future<T> {
    var result: Result?
    var handlers = [ResultHandler]()
    let start = DispatchTime.now()
    
    public typealias ResultHandler = ((Result) -> ())
    
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
    
    public func then(_ handler: @escaping ResultHandler) {
        futureManipulationQueue.sync {
            if let result = result {
                handler(result)
            } else {
                handlers.append(handler)
            }
        }
    }
    
    public func complete(_ closure: @escaping () throws -> T) throws {
        try futureManipulationQueue.sync {
            guard result == nil else {
                throw FutureError.alreadyCompleted
            }
        }
            
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
    
    public func map<B>(_ closure: @escaping ((T) throws -> (B))) throws -> Future<B> {
        return try Future<B>(transform: closure, from: self)
    }
    
    public init() {}
    
    public init(_ handler: @escaping ResultHandler) {
        self.handlers.append(handler)
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
}
