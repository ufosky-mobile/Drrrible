//
//  ShotListViewReactorTests.swift
//  Drrrible
//
//  Created by Suyeol Jeon on 22/03/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import XCTest

import RxCocoa
import RxExpect
import RxSwift
import RxTest

@testable import Drrrible
/*
final class ShotListViewReactorTests: TestCase {
  func testSections() {
    RxExpect { test in
      DI.register(ShotServiceType.self) { _ in
        StubShotService().then {
          $0.shotsClosure = { _ in .just(List(items: [ShotFixture.shot1, ShotFixture.shot2])) }
        }
      }
      let reactor = ShotListViewReactor()
      test.input(reactor.action, [
        next(100, .refresh),
      ])

      let sectionItemCount = reactor.state
        .map { $0.sections }
        .map { $0[0].items.count }
        .distinctUntilChanged()
      test.assert(sectionItemCount)
        .filterNext()
        .equal([
          0, // initial
          2, // after refreshing
        ])
    }
  }
}
*/
