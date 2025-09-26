//
//  UserDefaultsManager.swift
//  ModuClass
//
//  Created by 정성희 on 9/3/25.
//

import Foundation

class UserDefaultsManager {
    @UserDefault(key: "isOnboardingCompleted", defaultValue: false)
    static var isOnboardingCompleted: Bool
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
