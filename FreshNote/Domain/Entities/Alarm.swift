//
//  Alarm.swift
//  FreshNote
//
//  Created by SeokHyun on 10/25/24.
//

import Foundation

struct Alarm {
  var date: Int
  let hour: Int
  let minute: Int
  
  var dictionary: [String: Any] {
    return [
      "date": self.date,
      "hour": self.hour,
      "minute": self.minute
    ]
  }
}
