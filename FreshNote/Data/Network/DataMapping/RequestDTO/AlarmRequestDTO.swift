//
//  AlarmRequestDTO.swift
//  FreshNote
//
//  Created by SeokHyun on 11/28/24.
//

import Foundation

struct AlarmRequestDTO: Encodable {
  let date: Int
  let hour: Int
  let minute: Int
}
