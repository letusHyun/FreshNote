//
//  DateFormatManager.swift
//  FreshNote
//
//  Created by SeokHyun on 12/4/24.
//

import Foundation

struct DateFormatManager {
  private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy-MM-dd"
    return formatter
  }()
  
  /// dateFormat이 적용된 Date를 반환합니다.
  func makeCurrentDate() -> Date {
    let dateString = self.string(from: Date())
    return self.formatter.date(from: dateString)!
  }
  
  /// Date를 dateString으로 반환합니다.
  func string(from date: Date) -> String {
    return self.formatter.string(from: date)
  }
  
  func date(from string: String) -> Date? {
    return formatter.date(from: string)
  }
}
