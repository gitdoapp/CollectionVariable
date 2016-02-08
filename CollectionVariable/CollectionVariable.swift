import Foundation
import RxSwift

public enum CollectionChange<T> {
    case Remove(Int, T)
    case Insert(Int, T)
    case Composite([CollectionChange])
    
    public func index() -> Int? {
        switch self {
        case .Remove(let index, _): return index
        case .Insert(let index, _): return index
        default: return nil
        }
    }
    
    public func element() -> T? {
        switch self {
        case .Remove(_, let element): return element
        case .Insert(_, let element): return element
        default: return nil
        }
    }
}


public final class CollectionVariable<T> {
    
    // MARK: - Attributes
    
    private let _changesSubject: PublishSubject<CollectionChange<T>>
    private let _subject: PublishSubject<[T]>
    private var _lock = NSRecursiveLock()
    public var observable: Observable<[T]> { return _subject.asObservable() }
    public var changesObservable: Observable<CollectionChange<T>> { return _changesSubject.asObservable() }
    private var _value: [T]
    public var value: [T] {
        get {
            return _value
        }
        set {
            _value = newValue
            _subject.onNext(newValue)
            _changesSubject.onNext(.Composite(newValue.mapWithIndex{CollectionChange.Insert($0, $1)}))
        }
    }

    
    // MARK: - Init
    
    public init(_ value: [T]) {
        var initialChanges: [CollectionChange<T>] = []
        for (index, element) in value.enumerate() {
            initialChanges.append(.Insert(index, element))
        }
        _value = value
        _changesSubject = PublishSubject()
        _changesSubject.onNext(.Composite(initialChanges))
        _subject = PublishSubject()
        _subject.onNext(value)
    }
    
    
    // MARK: - Public
    
    public func removeFirst() {
        if (_value.count == 0) { return }
        _lock.lock()
        let deletedElement = _value.removeFirst()
        _changesSubject.onNext(.Remove(0, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeLast() {
        _lock.lock()
        if (_value.count == 0) { return }
        let index = _value.count - 1
        let deletedElement = _value.removeLast()
        _changesSubject.onNext(.Remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAll() {
        _lock.lock()
        let copiedValue = _value
        _value.removeAll()
        _changesSubject.onNext(.Composite(copiedValue.mapWithIndex{CollectionChange.Remove($0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAtIndex(index: Int) {
        _lock.lock()
        let deletedElement = _value.removeAtIndex(index)
        _changesSubject.onNext(CollectionChange.Remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func append(element: T) {
        _lock.lock()
        _value.append(element)
        _changesSubject.onNext(.Insert(_value.count - 1, element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func appendContentsOf(elements: [T]) {
        _lock.lock()
        let count = _value.count
        _value.appendContentsOf(elements)
        _changesSubject.onNext(.Composite(elements.mapWithIndex{CollectionChange.Insert(count + $0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func insert(newElement: T, atIndex index: Int) {
        _lock.lock()
        _value.insert(newElement, atIndex: index)
        _changesSubject.onNext(.Insert(index, newElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func replace(subRange: Range<Int>, with elements: [T]) {
        _lock.lock()
        precondition(subRange.startIndex + subRange.count <= _value.count, "Range out of bounds")
        var insertsComposite: [CollectionChange<T>] = []
        var deletesComposite: [CollectionChange<T>] = []
        for (index, element) in elements.enumerate() {
            let replacedElement = _value[subRange.startIndex+index]
            _value.replaceRange(Range<Int>(start: subRange.startIndex+index, end: subRange.startIndex+index+1), with: [element])
            deletesComposite.append(.Remove(subRange.startIndex + index, replacedElement))
            insertsComposite.append(.Insert(subRange.startIndex + index, element))
        }
        _changesSubject.onNext(.Composite(deletesComposite))
        _changesSubject.onNext(.Composite(insertsComposite))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    deinit {
        _subject.onCompleted()
        _changesSubject.onCompleted()
    }
    
}

extension Array {
    
    func mapWithIndex<T>(transform: (Int, Element) -> T) -> [T] {
        var newValues: [T] = []
        for (index, element) in self.enumerate() {
            newValues.append(transform(index, element))
        }
        return newValues
    }
    
}