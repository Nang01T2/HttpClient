//
//  APIRequestRetrier.swift
//  DevKit
//
//  Created by Nang Nguyen on 1/15/19.
//

import Foundation
import Alamofire

struct HTTPRequestRetrier: RequestRetrier {
    
    let count: Int
    
    func should(_ manager: SessionManager,
                retry request: Request,
                with error: Error,
                completion: @escaping RequestRetryCompletion) {
        //Logger.info("Retry request (\(request.retryCount + 1)) : \(request)")
        completion(request.retryCount < count - 1, 1)
    }
}
