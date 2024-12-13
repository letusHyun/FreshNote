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
  
  private lazy var calendarView: UICalendarView = {
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let calendarView = UICalendarView()
    calendarView.calendar = gregorianCalendar
    calendarView.locale = Locale(identifier: "ko_KR")
    calendarView.fontDesign = .default
    calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    return calendarView
  }()
  
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView()
    // TODO: - register
    cv.dataSource = self
    cv.delegate = self
    return cv
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
  
  // MARK: - UI
  override func setupLayout() {
    self.view.addSubview(self.calendarView)
    self.view.addSubview(self.collectionView)
    
    self.calendarView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.31)
    }
    
    self.collectionView.snp.makeConstraints {
      $0.top.equalTo(self.calendarView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
}

// MARK: - UICalendarSelectionSingleDateDelegate
extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
  func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
    guard let date = dateComponents?.date else { return }
    print("selected date: \(date)")
  }
}

// MARK: - UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    // TODO: - vm 연동
    return .zero
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    // TODO: - vm 연동
    return UICollectionViewCell()
  }
}

// MARK: - UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    // TODO: - 설정하기
    return .init(width: 10, height: 10)
  }
}
