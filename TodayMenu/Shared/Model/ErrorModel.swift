//
//  ErrorModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation

struct ErrorModel: Decodable {
    let message: String
    let errorType: String
    
    enum CodingKeys: CodingKey {
        case message
        case errorType
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        self.errorType = try container.decodeIfPresent(String.self, forKey: .errorType) ?? "Unknown"
    }
}

enum ErrorType: String, Error {
    case Unknown
    case NetworkDisconnected
    case ValidationError
    
    var message: String {
        switch self {
        case .Unknown: "알 수 없는 에러가 발생했습니다."
        case .NetworkDisconnected: "네트워크 연결이 일시적으로 원활하지 않습니다. 데이터 또는 Wi-Fi 연결 상태를 확인해주세요."
        case .ValidationError: "유효하지 않은 입력값입니다."
        }
    }
}
