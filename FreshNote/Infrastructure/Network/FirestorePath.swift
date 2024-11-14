//
//  FirestorePath.swift
//  FreshNote
//
//  Created by SeokHyun on 11/11/24.
//

import Foundation
import FirebaseFirestore

enum FirestorePath: String {
  case users
  case items
  
  static func userID(userID: String) -> String {
    return "\(users.rawValue)/\(userID)"
  }
  
  static func items(userID: String) -> String {
    return "\(users.rawValue)/\(userID)/\(items.rawValue)"
  }
  
  static func item(userID: String, itemID: String) -> String {
    return "\(users.rawValue)/\(userID)/\(items.rawValue)/\(itemID)"
  }
}
