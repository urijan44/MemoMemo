//
//  Date+Extension.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import Foundation

extension Date {
  var customDateString: String {
    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(self) {
      formatter.dateFormat = "a HH:mm"
    } else if self >= Date(timeIntervalSinceNow: 60 * 60 * 24 * -7) {
      formatter.dateFormat = "EEEE"
    } else {
      formatter.dateFormat = "yyyy. MM. dd. a hh:mm"
    }
    formatter.locale = .init(identifier: "ko_KR")
    return formatter.string(from: self)
  }
}


