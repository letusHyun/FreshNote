//
//  MainCoordiantor.swift
//  FreshNote
//
//  Created by SeokHyun on 10/27/24.
//

import UIKit

protocol MainCoordinatorDependencies: AnyObject {
  // todo: make각 탭Coordinator
  func makeHomeCoordinator(navigationController: UINavigationController) -> HomeCoordinator
  func makeCalendarCoordinator(navigationController: UINavigationController) -> CalendarCoordinator
}

final class MainCoordinator: BaseCoordinator {
  // MARK: - Properties
  private let dependencies: any MainCoordinatorDependencies
  private weak var tabBarController: UITabBarController? // window.rootVC가 강한참조를 하기 때문에 weak 선언
  
  init(
    dependencies: any MainCoordinatorDependencies,
    tabBarController: UITabBarController
  ) {
    self.dependencies = dependencies
    // tabBarController는 SceneDelegate에서 생성해서 여기로 주입해주어야 할듯.
    // 이유는 window객체가 SceneDelegate에 있기 때문
    self.tabBarController = tabBarController
    
    super.init(navigationController: nil)
  }
  
  func start() {
    // TODO: - 나머지 탭들도 구성해야합니다.
    // tabBarController에 들어갈 window에서 알 필요가 없기 때문에 내비컨들은 여기서 만들어주는것이 적합함
    let homeNaviController = self.makeNavigationController(
      title: "홈",
      tabBarImage: UIImage(systemName: "house"),
      tag: 0
    )
    let calendarNaviController = self.makeNavigationController(
      title: "캘린더",
      tabBarImage: UIImage(systemName: "calendar"),
      tag: 1
    )
    
    self.tabBarController?.tabBar.tintColor = UIColor(fnColor: .gray3)
    self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(fnColor: .gray1)
    self.tabBarController?.viewControllers = [homeNaviController, calendarNaviController]
    
    let homeCoordinator = self.dependencies.makeHomeCoordinator(navigationController: homeNaviController)
    self.childCoordinators[homeCoordinator.identifier] = homeCoordinator
    homeCoordinator.start()
    
    let calendarCoordinator = self.dependencies.makeCalendarCoordinator(navigationController: calendarNaviController)
    self.childCoordinators[calendarCoordinator.identifier] = calendarCoordinator
    calendarCoordinator.start()
  }
}

// MARK: - Private Helpers
private extension MainCoordinator {
  private func makeNavigationController(title: String, tabBarImage: UIImage?, tag: Int) -> UINavigationController {
    let navigationController = UINavigationController()
    navigationController.setupBarAppearance()
    
    let tabBarItem = UITabBarItem(
      title: title,
      image: tabBarImage,
      tag: tag
    )
    navigationController.tabBarItem = tabBarItem
    
    return navigationController
  }
}
