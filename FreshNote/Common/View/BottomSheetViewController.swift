//
//  BottomSheetViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/20/24.
//

import Combine
import UIKit

import SnapKit

/// 해당 ViewController를 사용하기 위해서 modalPresentationStyle을 .overFullScreen로 설정해야 합니다.
/// present의 animated도 false로 설정해야 합니다.
class BottomSheetViewController: BaseViewController {
  // MARK: - Nested
  enum ViewState {
    case expanded
    case normal
  }
  
  enum Detent {
    /// * 0.9
    case large
    /// * 0.7
    case smallLarge
    /// * 0.5
    case medium
    /// * 0.25
    case small
    /// 0
    case zero
    case custom(CGFloat)
    
    func calculateHeight(baseView: UIView) -> CGFloat {
      switch self {
        case .large:
        return baseView.frame.size.height * 0.9
      case .smallLarge:
        return baseView.frame.size.height * 0.7
      case .medium:
        return baseView.frame.size.height * 0.5
      case .small:
        return baseView.frame.size.height * 0.25
      case .zero:
        return .zero
      case .custom(let height):
        return height
      }
    }
  }
  
  // MARK: - Properties
  private var viewHeightExcludingSafeArea: CGFloat {
    self.view.safeAreaLayoutGuide.layoutFrame.height
  }
  
  private var safeAreaBottomHeight: CGFloat {
    if let window = self.view.window ?? UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow }) {
      return window.safeAreaInsets.bottom
    }
    return 0
  }

  /// bottomSheet과 safeArea Top 사이의 최솟값
  var bottomSheetPanMinTopConstant: CGFloat = 100
  
  /// 드래그 하기 전에 bottom sheet의 top constraint value를 지정하기 위한 프로퍼티
  private lazy var bottomSheetPanStartingTopConstraintConstant: CGFloat = self.bottomSheetPanMinTopConstant
  
  private var bottomSheetColor: UIColor {
    return UIColor(fnColor: .realBack)
  }
  
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    return view
  }()
  
  private(set) lazy var bottomSheetView: UIView = {
    let view = UIView()
    view.backgroundColor = self.bottomSheetColor
    view.layer.cornerRadius = 10
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.clipsToBounds = true
    return view
  }()
  
  private var bottomSheetViewTopConstraint: Constraint?
  
  private var subscriptions = Set<AnyCancellable>()
  
  private var bottomSheetHeight: CGFloat {
    self.detent.calculateHeight(baseView: self.view)
  }
  
  private let detent: Detent
  
  private let dragIndicatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: "#3C3C43", alpha: 0.3)
    view.layer.cornerRadius = 2.5
    view.alpha = .zero
    return view
  }()
  
  // MARK: - LifeCycle
  init(detent: Detent) {
    self.detent = detent
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLayout()
    self.setupGestureRecognizers()
    self.setupStyle()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.showBottomSheet()
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - setupUI
  override func setupStyle() {
    self.dimmedView.alpha = 0
    self.view.backgroundColor = .clear
  }
  
  override func setupLayout() {
    self.view.addSubview(self.dimmedView)
    self.view.addSubview(self.bottomSheetView)
    self.view.addSubview(self.dragIndicatorView)
    
    self.dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.bottomSheetView.snp.makeConstraints {
      $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
      $0.bottom.equalToSuperview()
      
      let topConstant = self.safeAreaBottomHeight + self.view.safeAreaLayoutGuide.layoutFrame.height
      self.bottomSheetViewTopConstraint = $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(topConstant).constraint
    }
    
    self.dragIndicatorView.snp.makeConstraints {
      $0.width.equalTo(36)
      $0.height.equalTo(self.dragIndicatorView.layer.cornerRadius * 2)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(self.bottomSheetView).inset(5)
    }
  }
  
  // MARK: - Private Helpers
  private func setupGestureRecognizers() {
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
    panGestureRecognizer.delaysTouchesBegan = false // 딜레이 제거
    panGestureRecognizer.delaysTouchesEnded = false // 딜레이 제거
    self.view.addGestureRecognizer(panGestureRecognizer)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(_:)))
    self.dimmedView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  private func hideBottomSheetAndDismiss() {
    let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
    let bottomPadding = self.safeAreaBottomHeight
    
    self.bottomSheetViewTopConstraint?.update(offset: safeAreaHeight + bottomPadding)
    
    UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseIn, animations: {
      let hiddenAlpha: CGFloat = 0
      self.dimmedView.alpha = hiddenAlpha
      self.dragIndicatorView.alpha = hiddenAlpha
      self.view.layoutIfNeeded()
    }) { _ in
      self.dismiss(animated: false)
    }
  }
  
  private func showBottomSheet(at state: ViewState = .normal) {
    if state == .normal {
      let height: CGFloat = self.view.safeAreaLayoutGuide.layoutFrame.height
      let bottomPadding: CGFloat = self.safeAreaBottomHeight
      
      self.bottomSheetViewTopConstraint?.update(offset: (height + bottomPadding) - self.bottomSheetHeight)
    } else {
      self.bottomSheetViewTopConstraint?.update(offset: self.bottomSheetPanMinTopConstant)
    }
    
    UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseIn, animations: {
      self.dimmedView.alpha = 0.7
      self.dragIndicatorView.alpha = 1
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  private func dimAlphaWithBottomSheetTopConstraint(value: CGFloat) -> CGFloat {
    let fullDimAlpha: CGFloat = 0.7
    
    let fullDimPosition = (self.viewHeightExcludingSafeArea + self.safeAreaBottomHeight - self.bottomSheetHeight) / 2
    
    let noDimPosition = self.viewHeightExcludingSafeArea + self.safeAreaBottomHeight
    
    if value < fullDimPosition {
      return fullDimAlpha
    }
    
    if value > noDimPosition {
      return 0.0
    }
    
    return fullDimAlpha * (1 - ((value - fullDimPosition) / (noDimPosition - fullDimPosition)))
  }
  
  /// number와 가장 가까운 값을 반환하는 메소드
  private func nearest(to number: CGFloat, in values: [CGFloat]) -> CGFloat {
    guard let nearestValue = values.min(by: { abs(number - $0) < abs(number - $1)})
    else { return number }
    
    return nearestValue
  }
  
  // MARK: - Actions
  @objc private func dimmedViewTapped(_ sender: UITapGestureRecognizer) {
    self.hideBottomSheetAndDismiss()
  }
  
  @objc private func viewPanned(_ panGestureRecognizer: UIPanGestureRecognizer) {
    guard let bottomSheetViewTopConstraintConstant = self.bottomSheetViewTopConstraint?
      .layoutConstraints.first?.constant
    else { return }
    
    let translation = panGestureRecognizer.translation(in: self.view)

    switch panGestureRecognizer.state {
      case .began:
      self.bottomSheetPanStartingTopConstraintConstant = bottomSheetViewTopConstraintConstant
    case .changed:
      // 제한 위치를 넘기지 않을때만
      if self.bottomSheetPanStartingTopConstraintConstant + translation.y > self.bottomSheetPanMinTopConstant {
        // bottomSheet constraint 변환
        self.bottomSheetViewTopConstraint?.update(offset: self.bottomSheetPanStartingTopConstraintConstant + translation.y)
      }
      self.dimmedView.alpha = self.dimAlphaWithBottomSheetTopConstraint(value: bottomSheetViewTopConstraintConstant)
      
    case .ended:
      let velocity = panGestureRecognizer.velocity(in: self.view)
      // 스와이프 속도가 빠르면 bottomSheet 종료
      if velocity.y > 1500 {
        self.hideBottomSheetAndDismiss()
        return
      }
      
      let bottomPadding = self.safeAreaBottomHeight
      let defaultPadding = self.viewHeightExcludingSafeArea + bottomPadding - self.bottomSheetHeight
      
      let nearestValue = self.nearest(
        to: bottomSheetViewTopConstraintConstant,
        in: [self.bottomSheetPanMinTopConstant, defaultPadding, self.viewHeightExcludingSafeArea + bottomPadding]
      )

      if nearestValue == self.bottomSheetPanMinTopConstant { // bottomSheet이 safeAreaTop과 가장 가까운 경우
        self.showBottomSheet(at: .expanded)
      } else if nearestValue == defaultPadding { // bottomSheet이 viewHeightExcludingSafeArea에 가까운 경우
        // bottom sheet을 normal상태로 보여주기
        self.showBottomSheet(at: .normal)
      } else { // bottomSheet이 view.bottom에 가까운 경우
        // bottom sheet을 숨기고 현재 viewController를 dismiss시키기
        self.hideBottomSheetAndDismiss()
      }
    default:
      break
    }
  }
}
