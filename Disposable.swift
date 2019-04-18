//
//  Disposable.swift
//  morphin
//
//  Created by favre on 15/03/2019.
//  Copyright © 2019 mellonmellon. All rights reserved.
//

import Foundation

public protocol Disposable {
  func dispose()
}

extension Disposable {
  func disposed(by bag: DisposeBag) {
    bag.add(self)
  }
}

public class DisposeBag {
  
  var disposables: [Disposable] = []
  
  func add(_ disposable: Disposable) {
    disposables.append(disposable)
    print("new dispose bag count: \(disposables.count)")
  }
  
  func dispose() {
    disposables.forEach({$0.dispose()})
  }
  
  // When our view controller deinits, our dispose bag will deinit as well
  // and trigger the disposal of all corresponding observers living in the
  // Observable, which Disposable has a weak reference to: 'owner'.
  deinit {
    dispose()
  }
}
