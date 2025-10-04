//
//  NetworkManager.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    func callRequest<T: Decodable>(router: NetworkRouter, decodingType: T.Type) -> Observable<Result<T, ErrorType>> {
            return Observable<Result<T, ErrorType>>.create { observer in
                let url = router.URL
                AF.request(url,
                           method: router.method,
                           parameters: router.parameter,
                           encoding: router.encodingType,
                           headers: router.header)
                .validate(statusCode: 200...300)
                .responseDecodable(of: T.self, emptyResponseCodes: [200]) { response in
 
                    switch response.result {
                    case .success(let value):
                        observer.onNext(.success(value))
                        observer.onCompleted()
                    case .failure:
                        
                        // 네트워크 연결 오류 상태
                        if let error = response.error, let afError = error.asAFError {

                            if case let .sessionTaskFailed(underlyingError) = afError,
                                (underlyingError as? URLError) != nil {
                                let error = ErrorType.NetworkDisconnected
                                observer.onNext(.failure(error))
                                observer.onCompleted()
                            }
                        }

                        // 데이터가 아예 없는 경우
                        guard let data = response.data else {
                            let error = ErrorType.Unknown
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                            return
                        }
                        
                        // 네트워크 연결 성공
                        do {
                            let data = try JSONDecoder().decode(ErrorModel.self, from: data)
                            let errorType = data.errorType
                            let error = ErrorType(rawValue: errorType) ?? .Unknown
                            
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                            
                        // 그 외의 알 수 없는 오류
                        } catch {
                            let error = ErrorType.Unknown
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        }
}
