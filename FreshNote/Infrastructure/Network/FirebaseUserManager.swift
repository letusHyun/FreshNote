//
//  FirebaseUserManager.swift
//  FreshNote
//
//  Created by SeokHyun on 11/13/24.
//

import Foundation
import FirebaseAuth

class FirebaseUserManager {
  static let shared = FirebaseUserManager()
  
  private init() { }
  
  var userID: String? {
    Auth.auth().currentUser?.uid
  }
  
  var isAuthenticated: Bool {
    Auth.auth().currentUser != nil
  }
}
