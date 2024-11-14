//
//  DTOable.swift
//  FreshNote
//
//  Created by SeokHyun on 11/12/24.
//

import Foundation

struct AlarmDTO: DTOable {
  var date: Int
  let hour: Int
  let minute: Int
  
  init(date: Int, hour: Int, minute: Int) {
    self.date = date
    self.hour = hour
    self.minute = minute
  }
  
  init?(dictionary: [String : Any]) {
    guard let date = dictionary["date"] as? Int,
          let hour = dictionary["hour"] as? Int,
          let minute = dictionary["minute"] as? Int else { return nil }
    
    self.date = date
    self.hour = hour
    self.minute = minute
  }
  
  var dictionary: [String : Any] {
    [
      "date": date,
      "hour": hour,
      "minute": minute
    ]
  }
}

extension AlarmDTO {
  func toDomain() -> Alarm {
    return Alarm(
      date: date,
      hour: hour,
      minute: minute
    )
  }
}
