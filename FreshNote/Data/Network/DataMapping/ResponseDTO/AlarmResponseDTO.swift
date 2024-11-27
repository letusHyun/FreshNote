//
//  AlarmResponseDTO.swift
//  FreshNote
//
//  Created by SeokHyun on 11/28/24.
//

import Foundation

struct AlarmResponseDTO: Decodable {
  let date: Int
  let hour: Int
  let minute: Int
}

extension AlarmResponseDTO {
  func toDomain() -> Alarm {
    return Alarm(
      date: date,
      hour: hour,
      minute: minute
    )
  }
}
