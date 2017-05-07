import Foundation
import RxSwift

public enum CollectionChange<T> {
    case remove(Int, T)
    case insert(Int, T)
    case composite([CollectionChange])
    
    public func index() -> Int? {
        switch self {
        case .remove(let index, _): return index
        case .insert(let index, _): return index
        default: return nil
        }
    }
    
    public func element() -> T? {
        switch self {
        case .remove(_, let element): return element
        case .insert(_, let element): return element
        default: return nil
        }
    }
}


public final class CollectionVariable<T> {
    
    // MARK: - Attributes
    
    fileprivate let _changesSubject: PublishSubject<CollectionChange<T>>
    fileprivate let _subject: PublishSubject<[T]>
    fileprivate var _lock = NSRecursiveLock()
    public var observable: Observable<[T]> { return _subject.asObservable() }
    public var changesObservable: Observable<CollectionChange<T>> { return _changesSubject.asObservable() }
    fileprivate var _value: [T]
    public var value: [T] {
        get {
            return _value
        }
        set {
            _value = newValue
            _subject.onNext(newValue)
            _changesSubject.onNext(.composite(newValue.mapWithIndex{.insert($0, $1)}))
        }
    }

    
    // MARK: - Init
    
    public init(_ value: [T]) {
        var initialChanges: [CollectionChange<T>] = []
        for (index, element) in value.enumerated() {
            initialChanges.append(.insert(index, element))
        }
        _value = value
        _changesSubject = PublishSubject()
        _changesSubject.onNext(.composite(initialChanges))
        _subject = PublishSubject()
        _subject.onNext(value)
    }
    
    
    // MARK: - Public
    
    public func removeFirst() {
        if (_value.count == 0) { return }
        _lock.lock()
        let deletedElement = _value.removeFirst()
        _changesSubject.onNext(.remove(0, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeLast() {
        _lock.lock()
        if (_value.count == 0) { return }
        let index = _value.count - 1
        let deletedElement = _value.removeLast()
        _changesSubject.onNext(.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAll() {
        _lock.lock()
        let copiedValue = _value
        _value.removeAll()
        _changesSubject.onNext(.composite(copiedValue.mapWithIndex{.remove($0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAtIndex(_ index: Int) {
        _lock.lock()
        let deletedElement = _value.remove(at: index)
        _changesSubject.onNext(.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func append(_ element: T) {
        _lock.lock()
        _value.append(element)
        _changesSubject.onNext(.insert(_value.count - 1, element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func appendContentsOf(_ elements: [T]) {
        _lock.lock()
        let count = _value.count
        _value.append(contentsOf: elements)
        _changesSubject.onNext(.composite(elements.mapWithIndex{.insert(count + $0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func insert(_ newElement: T, atIndex index: Int) {
        _lock.lock()
        _value.insert(newElement, at: index)
        _changesSubject.onNext(.insert(index, newElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func replace(_ subRange: Range<Int>, with elements: [T]) {
        _lock.lock()
        precondition(subRange.lowerBound + subRange.count <= _value.count, "Range out of bounds")
        
        var compositeChanges: [CollectionChange<T>] = []
        
        for (index, element) in elements.enumerated() {
            let replacedElement = _value[subRange.lowerBound+index]
            let range = subRange.lowerBound+index..<subRange.lowerBound+index+1
            _value.replaceSubrange(range, with: [element])
            compositeChanges.append(.remove(subRange.lowerBound + index, replacedElement))
            compositeChanges.append(.insert(subRange.lowerBound + index, element))
        }
        _changesSubject.onNext(.composite(compositeChanges))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    deinit {
        _subject.onCompleted()
        _changesSubject.onCompleted()
    }
    
}

extension Array {
    
    func mapWithIndex<T>(_ transform: (Int, Element) -> T) -> [T] {
        var newValues: [T] = []
        for (index, element) in self.enumerated() {
            newValues.append(transform(index, element))
        }
        return newValues
    }
    
}
