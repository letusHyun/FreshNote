//
//  AlarmDateTimeDTO.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import FirebaseFirestore

struct AlarmDateTimeDTO: Codable {
  var dDay: Int?
  var time: String?
}
