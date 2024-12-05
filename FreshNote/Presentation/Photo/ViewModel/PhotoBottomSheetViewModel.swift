//
//  PhotoBottomSheetViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 11/23/24.
//

import Foundation

struct PhotoBottomSheetViewModelActions {
  let passData: (Data?) -> Void
}

typealias PhotoBottomSheetViewModel = PhotoBottomSheetViewModelInput & PhotoBottomSheetViewModelOutput

protocol PhotoBottomSheetViewModelInput {
  func didTapAlbumButton() 
  func didTapCameraButton()
  func didTapDeleteButton()
  func didFinishPickingMediaWithInfo(data: Data)
}

protocol PhotoBottomSheetViewModelOutput {
  
}

final class DefaultPhotoBottomSheetViewModel: PhotoBottomSheetViewModel {
  // MARK: - Properties
  private let actions: PhotoBottomSheetViewModelActions
  
  // MARK: - Output
  
  // MARK: - LifeCycle
  init(actions: PhotoBottomSheetViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - Input
  func didTapAlbumButton() {
    // actions을 통해 bottomSheet 제거 + productVM에게 picker 띄우라고 알림 -> vm의 output으로 VC가 피커 띄움
    print("사진 보관함 탭")
  }
  
  func didTapCameraButton() {
    print("사진 찍기 탭")
  }
  
  func didTapDeleteButton() {
    // 삭제 시, productVM에서 감지 해야 함.
    print("현재 사진 삭제 탭")
  }
  
  func didFinishPickingMediaWithInfo(data: Data) {
    self.actions.passData(data)
  }
}
