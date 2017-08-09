import Dispatch

public struct SchrodingerTimeInterval : Comparable, Equatable {
    public static func <(lhs: SchrodingerTimeInterval, rhs: SchrodingerTimeInterval) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }
    
    public static func ==(lhs: SchrodingerTimeInterval, rhs: SchrodingerTimeInterval) -> Bool {
        return lhs.nanoseconds == rhs.nanoseconds
    }
    
    public var dispatchTimeInterval: DispatchTimeInterval {
        return DispatchTimeInterval.nanoseconds(self.nanoseconds)
    }
    
    fileprivate var nanoseconds: Int
    
    public init(nanoseconds: Int) {
        self.nanoseconds = nanoseconds
    }
}

public func +(lhs: DispatchTime, rhs: SchrodingerTimeInterval) -> DispatchTime {
    return lhs + rhs.dispatchTimeInterval
}

public func +(lhs: SchrodingerTimeInterval, rhs: SchrodingerTimeInterval) -> SchrodingerTimeInterval {
    return SchrodingerTimeInterval(nanoseconds: lhs.nanoseconds + rhs.nanoseconds)
}

public func *(lhs: SchrodingerTimeInterval, rhs: Int) -> SchrodingerTimeInterval {
    return SchrodingerTimeInterval(nanoseconds: lhs.nanoseconds * rhs)
}

public func *(lhs: Int, rhs: SchrodingerTimeInterval) -> SchrodingerTimeInterval {
    return SchrodingerTimeInterval(nanoseconds: lhs * rhs.nanoseconds)
}

extension Integer {
    public var weeks: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 7 * 24 * 3600_000_000_000))
    }
    
    public var days: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 24 * 3600_000_000_000))
    }
    
    public var hours: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 3600_000_000_000))
    }
    
    public var minutes: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 60_000_000_000))
    }
    
    public var seconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000_000_000))
    }
    
    public var milliseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000_000))
    }
    
    public var microseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000))
    }
    
    public var nanoseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self))
    }
}

extension Double {
    public var weeks: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 7 * 24 * 60_000_000_000))
    }
    
    public var days: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 24 * 3600_000_000_000))
    }
    
    public var hours: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 3600_000_000_000))
    }
    
    public var minutes: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 60_000_000_000))
    }
    
    public var seconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000_000_000))
    }
    
    public var milliseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000_000))
    }
    
    public var microseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self * 1_000))
    }
    
    public var nanoseconds: SchrodingerTimeInterval {
        return SchrodingerTimeInterval(nanoseconds: Int(self))
    }
}
