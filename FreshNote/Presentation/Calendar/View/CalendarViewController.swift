//
//  CalendarViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import Combine
import Foundation
import UIKit

import SnapKit

final class CalendarViewController: BaseViewController {
  // MARK: - Properties
  private let viewModel: any CalendarViewModel
  
  private let calendarView: UICalendarView = {
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let calendarView = UICalendarView(frame: .zero, calendar: gregorianCalendar)
    calendarView.locale = Locale(identifier: "ko_KR")
    calendarView.fontDesign = .default
    return calendarView
  }()
  
  // MARK: - LifeCycle
  init(viewModel: any CalendarViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
