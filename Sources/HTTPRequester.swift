//
//  HTTPRequester.swift
//  DevKit
//
//  Created by Nang Nguyen on 3/29/19.
//

import Foundation
import Moya
import Alamofire
import RxSwift
import PromiseKit

public protocol HTTPRequesterProtocol {
    func requestSimple(_ request: TargetType, _ completion: @escaping Completion)
    func requestObject<T: Parceable>( _ request : TargetType, _ completion: @escaping (HTTPResult<T>) -> Void )
    func requestDecodable<T: Decodable>(_ request: TargetType, decoder: AnyDecoder, _ completion: @escaping (HTTPResult<T>) -> Void)
    
    // MARK: Rx-related methods
    func requestSimple(_ request: TargetType) -> Observable<Response>
    func requestDecodable<T: Decodable>(_ request: TargetType, decoder: AnyDecoder) -> Observable<T>
    func requestObject<T: Parceable>(_ request: TargetType) -> Observable<T>
    
    // MARK: Promise-related methods
    func requestDecodable<T: Decodable>(_ request: TargetType, decoder: AnyDecoder) -> Promise<T>
}

public class HTTPRequester: HTTPRequesterProtocol {
    
    public enum Level {
        case `default`
        case stubbed
        case custom
    }

    
    public static let `default` = HTTPRequester(level: .default)
    public static let stub = HTTPRequester(level: .stubbed)
    
    private let provider: MoyaProvider<MultiTarget>
    private let queue = OperationQueue()
        
    public init(level: HTTPRequester.Level, provider: MoyaProvider<MultiTarget> = HTTPRequester.defaultProvider()) {
        switch level {
        case .default:
            self.provider = HTTPRequester.defaultProvider()
        case .stubbed:
            let plugins = [NetworkLoggerPlugin(verbose: true, cURL: false, output: HTTPRequester.print)]
            self.provider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub,
                                                          //manager: HTTPRequester.defaultManager(),
                                                          plugins: plugins,
                                                          trackInflights: true)
        case .custom:
            self.provider = provider
        }
    }
    
    public func requestSimple(_ request: TargetType, _ completion: @escaping Completion) {
        provider.request(MultiTarget(request)) { (result) in
            completion(result)
        }
    }
    
    public func requestObject<T: Parceable>( _ request : TargetType, _ completion: @escaping (HTTPResult<T>) -> Void ) {
        self.provider.request(MultiTarget(request)) { result in
            do {
                let response = try result.get()
                switch T.parseResponse(response) {
                case .success(let value):
                    completion(.success(value))
                case .failure(let err):
                    completion(.failure(err))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
        
//        let q = queue
//        let currentQueue = OperationQueue.current!
//        provider.request(MultiTarget(request), completion: { (result) in
//            q.addOperation({
//                let mapper: MoyaMapping<RequestType.T> = request.mapping
//                var response: RequestType.T
//                switch result {
//                case .success(let value):
//                    response = mapper.map(.success(value))
//                case .failure(let error):
//                    response = mapper.map(.failure(error))
//                }
//                currentQueue.addOperation({
//                    completion(response)
//                })
//            })
//        })
    }
    
    public func requestDecodable<T>(_ request: TargetType, decoder: AnyDecoder = JSONDecoder(), _ completion: @escaping (HTTPResult<T>) -> Void) where T : Decodable {
        
        provider.request(MultiTarget(request)) { (result) in
            switch result {
            case .success(let value):
                do {
                    let data = try value.data.decoded(using: decoder) as T
                    completion(HTTPResult.success(data))
                } catch {
                    completion(HTTPResult.failure(error))
                }
            case .failure(let error):
                completion(HTTPResult.failure(error))
            }
        }
    }
}

extension HTTPRequester {
    
    public static func defaultProvider() -> MoyaProvider<MultiTarget> {
        
        //configure a custom MoyaProvider
        let endpointClosure = { (target: MultiTarget) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            //return defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "TODO: APP NAME"])
            return defaultEndpoint
        }
        
        //add the logger plugin
        let loggingPlugin = NetworkLoggerPlugin(verbose: true, cURL: false, output: HTTPRequester.print)
        
        let moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure,
                                                     //manager: HTTPRequester.defaultManager(),
                                                     plugins: [loggingPlugin],
                                                     trackInflights: true)
        
        return moyaProvider
    }
    
//    static func defaultManager() -> Manager {
//
//        let timeout = 30.0
//        //let host = URLComponents(url: Config.shared.kBaseURL, resolvingAgainstBaseURL: true)!.host!
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = timeout
//        sessionConfig.timeoutIntervalForResource = timeout
//
//        let serverTrust = ServerTrustPolicyManager(policies: [host: .disableEvaluation])
//        let manager = Manager(configuration: sessionConfig, serverTrustPolicyManager: serverTrust)
//        manager.retrier = HTTPRequestRetrier(count: 3)
//
//        return manager
//    }
}

extension HTTPRequester {
    
    public static func print(_ seperator: String,_ terminator: String, _ items: Any...) -> Void {
        let log = items.reduce("", { (prev, item) in
            return "\(prev)\(seperator)\(item)"})
        
        //Logger.verbose(log)
        Swift.print(log)
    }
}

/// MARK: Rx-related methods
public extension HTTPRequester {
    
    func requestSimple(_ request: TargetType) -> Observable<Response> {
        return self.doRequest(request)
    }
    
    func requestDecodable<T: Decodable>(_ request: TargetType, decoder: AnyDecoder = JSONDecoder()) -> Observable<T> {
        return self.doRequest(request).flatMap({ (response) -> Observable<T> in
            return Observable.just(try response.data.decoded(using: decoder) as T)
        })
    }
    
    func requestObject<T: Parceable>(_ request: TargetType) -> Observable<T> {
        return Observable.create { observer in
            let cancellableToken = self.provider.request(MultiTarget(request)) { result in
                do {
                    let response = try result.get()
                    switch T.parseResponse(response) {
                    case .success(let value):
                        observer.onNext(value)
                    case .failure(let err):
                        observer.onError(err)
                    }
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
    
    private func doRequest(_ target: TargetType) -> Observable<Response> {
        return Observable.create { observer in
            let cancellableToken = self.provider.request(MultiTarget(target)) { result in
                do {
                    let response = try result.get()
                    observer.onNext(response)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
}

/// MARK: Promise-related methods
public extension HTTPRequester {
    func requestDecodable<T: Decodable>(_ request: TargetType, decoder: AnyDecoder = JSONDecoder()) -> Promise<T> {
        return Promise { seal in
            provider.request(MultiTarget(request)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let data = try response.data.decoded(using: decoder) as T
                        seal.fulfill(data)
                    } catch {
                        seal.reject(error)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
