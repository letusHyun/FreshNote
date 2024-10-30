//
//  FirestoreCollectionPath.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import FirebaseFirestore

//   C       D      C      D
// users / user / Items / Item
// users / user / Items / alarm
enum FirestoreCollectionPath {
  case items(userID: String)
}

extension FirestoreCollectionPath {
  func reference() -> CollectionReference {
    let db = Firestore.firestore()
    
    switch self {
    case .items(let userID):
      return db.collection("users").document(userID).collection("items")
    }
  }
}

