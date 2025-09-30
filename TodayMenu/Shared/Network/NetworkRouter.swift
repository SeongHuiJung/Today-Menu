//
//  NetworkRouter.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation
import Alamofire

enum NetworkRouter {
    
    struct SearchPlaceDataSet {
        let query: String
        let categoryGroupCode: String
        let latitude: String
        let longitude: String
    }
    
    case searchPlace(searchPlaceDataSet: SearchPlaceDataSet)
    
    var URL: String {
        switch self {
        case .searchPlace: URLData.baseURL + EndPoint.searchPlace
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchPlace: HTTPMethod.get
        }
    }
    
    var parameter: Parameters {
        switch self {
        case .searchPlace(let searchPlaceDataSet): ["query" : searchPlaceDataSet.query,
                                                    "category_group_code" : searchPlaceDataSet.categoryGroupCode,
                                                    "x" : searchPlaceDataSet.longitude,
                                                    "y" : searchPlaceDataSet.latitude]
        }
    }
    
    var encodingType: ParameterEncoding {
        switch self {
        case .searchPlace: URLEncoding.default
        }
    }
    
    var header: HTTPHeaders {
        switch self {
        case .searchPlace: [
            "Content-Type": "application/json",
            "Authorization": APIKeyManager.shared.kakaoKey
        ]
        }
    }
}
