//
//  MainSceneDIContainer.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import UIKit

final class MainSceneDIContainer {
  
  struct Dependencies {
    // service객체
  }
  
  // MARK: - Properties
  private let dependencies: Dependencies
  
  // MARK: - LifeCycle
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

private extension MainSceneDIContainer {
  // MARK: - Presentation Layer
  func makeHomeViewModel(actions: HomeViewModelActions) -> any HomeViewModel {
    return DefaultHomeViewModel(
      actions: actions,
      fetchProductUseCase: self.makefetchProductUseCase(),
      deleteProductUseCase: self.makeDeleteProductUseCase()
    )
  }
  
  func makeCalendarViewModel(actions: CalendarViewModelActions) -> any CalendarViewModel {
    return DefaultCalendarViewModel(actions: actions)
  }
  
  func makeNotificationViewModel(actions: NotificationViewModelActions) -> any NotificationViewModel {
    return DefaultNotificationViewModel(actions: actions)
  }
  
  func makeSearchViewModel(actions: SearchViewModelActions) -> any SearchViewModel {
    return DefaultSearchViewModel(actions: actions)
  }
  
  func makeProductViewModel(actions: ProductViewModelActions, mode: ProductViewModelMode) -> any ProductViewModel {
    return DefaultProductViewModel(saveProductUseCase: self.makeSaveProductUseCase(), actions: actions, mode: mode)
  }
  
  func makePhotoBottomSheetViewModel(actions: PhotoBottomSheetViewModelActions) -> any PhotoBottomSheetViewModel {
    return DefaultPhotoBottomSheetViewModel(actions: actions)
  }
  
  func makeCategoryBottomSheetViewModel(
    actions: CategoryBottomSheetViewModelActions
  ) -> any CategoryBottomSheetViewModel {
    return DefaultCategoryBottomSheetViewModel(actions: actions)
  }
  
  // MARK: - Domain Layer
  func makeDeleteProductUseCase() -> any DeleteProductUseCase {
    return DefaultDeleteProductUseCase(
      imageRepository: self.makeImageRepository(),
      productRepository: self.makeProductRepository()
    )
  }
  
  func makeSaveProductUseCase() -> any SaveProductUseCase {
    return DefaultSaveProductUseCase(
      productRepository: self.makeProductRepository(),
      imageRepository: self.makeImageRepository()
    )
  }
  
  func makefetchProductUseCase() -> any FetchProductUseCase {
    return DefaultFetchProductUseCase(productRepository: self.makeProductRepository())
  }
  
  // MARK: - Data Layer
  func makeProductRepository() -> any ProductRepository {
    return DefaultProductRepository(firebaseNetworkService: self.makeFirebaseNetworkService())
  }
  
  func makeImageRepository() -> any ImageRepository {
    return DefaultImageRepository(firebaseNetworkService: self.makeFirebaseNetworkService())
  }
  
  func makeFirebaseNetworkService() -> any FirebaseNetworkService {
    return DefaultFirebaseNetworkService()
  }
}

// MARK: - MainCoordinatorDependencies
extension MainSceneDIContainer: MainCoordinatorDependencies {
  func makeCalendarCoordinator(navigationController: UINavigationController) -> CalendarCoordinator {
    return CalendarCoordinator(navigationController: navigationController, dependencies: self)
  }
  
  func makeHomeCoordinator(navigationController: UINavigationController) -> HomeCoordinator {
    return HomeCoordinator(navigationController: navigationController, dependencies: self)
  }
}

// MARK: - HomeCoordinatorDependencies
extension MainSceneDIContainer: HomeCoordinatorDependencies {
  func makeProductCoordinator(
    navigationController: UINavigationController?,
    mode: ProductViewModelMode
  ) -> ProductCoordinator {
    return ProductCoordinator(
      dependencies: self,
      navigationController: navigationController,
      mode: mode
    )
  }
  
  func makeSearchCoordinator(navigationController: UINavigationController?) -> SearchCoordinator {
    return SearchCoordinator(dependencies: self, navigationController: navigationController)
  }
  
  func makeNotificationCoordinator(navigationController: UINavigationController?) -> NotificationCoordinator {
    return NotificationCoordinator(dependencies: self, navigationController: navigationController)
  }
  
  func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController {
    return HomeViewController(viewModel: self.makeHomeViewModel(actions: actions))
  }
}

// MARK: - CalendarCoordinatorDependencies
extension MainSceneDIContainer: CalendarCoordinatorDependencies {
  func makeCalendarViewController(actions: CalendarViewModelActions) -> CalendarViewController {
    return CalendarViewController(viewModel: self.makeCalendarViewModel(actions: actions))
  }
}

// MARK: - NotificationCoordinatorDependencies
extension MainSceneDIContainer: NotificationCoordinatorDependencies {
  func makeNotificationViewController(actions: NotificationViewModelActions) -> NotificationViewController {
    return NotificationViewController(viewModel: self.makeNotificationViewModel(actions: actions))
  }
}

// MARK: - SearchCoordinatorDependencies
extension MainSceneDIContainer: SearchCoordinatorDependencies {
  func makeSearchViewController(actions: SearchViewModelActions) -> SearchViewController {
    return SearchViewController(viewModel: self.makeSearchViewModel(actions: actions))
  }
}

extension MainSceneDIContainer: ProductCoordinatorDependencies {
  func makeCategoryBottomSheetViewController(actions: CategoryBottomSheetViewModelActions) -> UIViewController {
    return CategoryBottomSheetViewController(viewModel: self.makeCategoryBottomSheetViewModel(actions: actions))
  }
  
  func makeBottomSheetViewController(
    detent: BottomSheetViewController.Detent
  ) -> BottomSheetViewController {
    return BottomSheetViewController(detent: detent)
  }
  
  func makePhotoBottomSheetViewController(actions: PhotoBottomSheetViewModelActions) -> UIViewController {
    return PhotoBottomSheetViewController(viewModel: self.makePhotoBottomSheetViewModel(actions: actions))
  }
  
  func makeProductViewController(
    actions: ProductViewModelActions,
    mode: ProductViewModelMode
  ) -> ProductViewController {
    return ProductViewController(viewModel: self.makeProductViewModel(actions: actions, mode: mode))
  }
}
