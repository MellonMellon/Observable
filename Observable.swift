//
//  Observable.swift
//  morphin
//
//  Created by favre on 15/03/2019.
//  Copyright © 2019 mellonmellon. All rights reserved.
//

import Foundation
/*
public class ImmutableObservable<T> {
  
  public typealias Observer = (T, T?) -> Void
  
  private var observers: [Int: (Observer, DispatchQueue?)] = [:]
  private var uniqueID = (0...).makeIterator()
  
  fileprivate let lock: Lock = Mutex()
  
  fileprivate var _value: T {
    didSet {
      observers.values.forEach { observer, dispatchQueue in
        
        if let dispatchQueue = dispatchQueue {
          dispatchQueue.async {
            observer(self.value, oldValue)
          }
        } else {
          observer(value, oldValue)
        }
      }
    }
  }
  
  public var value: T {
    return _value
  }
  
  public init(_ value: T) {
    self._value = value
  }
  
  public func observe(_ queue: DispatchQueue? = nil, _ observer: @escaping Observer) -> Disposable {
    lock.lock()
    defer { lock.unlock() }
    
    let id = uniqueID.next()!
    
    observers[id] = (observer, queue)
    observer(value, nil)
    
    let disposable = Disposable { [weak self] in
      self?.observers[id] = nil
    }
    
    return disposable
  }
  
  public func removeAllObservers() {
    observers.removeAll()
  }
}

public class Observable<T>: ImmutableObservable<T> {
  
  public override var value: T {
    get {
      return _value
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _value = newValue
    }
  }
}*/

class Observable<T> {
  
  typealias Observer = (T) -> Void
  private(set) var observers = [Int: Observer]()
  fileprivate let lock: Lock = Mutex()
  func observe(_ observer: @escaping Observer)-> Disposable {
    
    let uniqueKey = Int(arc4random_uniform(10000))
    
    // add observer to observers
    observers[uniqueKey] = (observer)
    
    print("total observer count: \(observers.keys.count)")
    
    return ObserverDisposable(owner: self, key: uniqueKey)
  }
  
  func updateObservers() {
    for (index, observer) in observers {
     self.update(observer: observer, index: index)
      // iterate over all observers,
      // and call closure with new value.
    }
  }
  
  func update(observer: @escaping Observer, index: Int) {
    let queue = DispatchQueue.init(label: "observable_\(index)", qos: .background)
    queue.async { [weak self] in
      guard let `self` = self else { return }
      self.lock.lock()
      defer { self.lock.unlock() }
      
      observer(self.value)
    }
  }
  
  fileprivate var _value: T {
    didSet {
      updateObservers()
    }
  }
  
  public var value: T {
    get {
      return _value
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _value = newValue
    }
  }
  
  func removeObserver(with key: Int) {
    if observers.keys.contains(key) {
      observers.removeValue(forKey: key)
      updateObservers()
    }
  }
  
  init(_ v: T) {
    _value = v
  }
}

class ObserverDisposable<T>: Disposable {
  
  var key: Int
  weak var owner: Observable<T>?
  
  init(owner: Observable<T>, key: Int) {
    self.owner = owner
    self.key = key
  }
  
  func dispose() {
    self.owner?.removeObserver(with: key)
  }
}

