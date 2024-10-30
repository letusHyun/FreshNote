//
//  BaseViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/19/24.
//

import UIKit

class BaseViewController: UIViewController {
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // MARK: - UI
  func setupUI() {
    setupStyle()
    setupLayout()
  }
  
  func setupStyle() {
    self.view.backgroundColor = UIColor(fnColor: .realBack)
  }
  
  func setupLayout() { }
}
