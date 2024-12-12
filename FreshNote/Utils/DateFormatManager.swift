//
//  DateFormatManager.swift
//  FreshNote
//
//  Created by SeokHyun on 12/4/24.
//

import Foundation

struct DateFormatManager {
  // 날짜와 시간을 모두 포함하는 포맷
  private let fullFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd HH:mm:ss"
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
  }()
  
  // 날짜만 포함하는 포맷
  private let displayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd"
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
  }()
  
  func makeCurrentDate() -> Date {
    let now = Date()
    let fullDateString = fullFormatter.string(from: now)
    return fullFormatter.date(from: fullDateString) ?? now
  }
  
  func string(from date: Date) -> String {
    return displayFormatter.string(from: date)
  }
  
  func date(from string: String) -> Date? {
    return displayFormatter.date(from: string)
  }
}
