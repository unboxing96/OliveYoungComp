//
//  AppState.swift
//  OliveYoungComp
//
//  Created by 김태현 on 5/26/24.
//

import Foundation

class AppState {
    static let shared = AppState()
    private init() {}
    
    var lastLoadedURL: URL?
    var initialLoadCompleted: Bool = false
}
