//
//  DTOable.swift
//  DTOable
//
//  Created by SeokHyun on 11/12/24.
//

import Foundation

protocol DTOable {
  init?(dictionary: [String: Any])
  
  var dictionary: [String: Any] { get }
}
