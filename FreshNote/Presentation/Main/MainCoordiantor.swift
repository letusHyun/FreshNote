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
    let homeNaviController = UINavigationController()
    let calendarNaviController = UINavigationController()
    tabBarController?.viewControllers = [homeNaviController, calendarNaviController]
    homeNaviController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
    calendarNaviController.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)
    let homeCoordinator = dependencies.makeHomeCoordinator(navigationController: homeNaviController)
    let calendarCoordinator = dependencies.makeCalendarCoordinator(navigationController: calendarNaviController)
    childCoordinators[homeCoordinator.identifier] = homeCoordinator
    homeCoordinator.start()
    childCoordinators[calendarCoordinator.identifier] = calendarCoordinator
    calendarCoordinator.start()
  }
}
