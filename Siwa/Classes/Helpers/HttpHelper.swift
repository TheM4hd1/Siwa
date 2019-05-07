//
//  HttpHelper.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

struct Headers {
    
    private init() {}
    
    static let HeaderAcceptLanguageKey = "Accept-Language"
    static let HeaderAcceptLanguageValue = "en-US,en;q=0.5"
    static let HeaderUserAgentKey = "User-Agent"
    static let HeaderUserAgentValue = "Instagram 78.0.0.9.103 Android (21/5.0.2; 480dpi; 1080x1776; Sony; C6603; C6603; qcom; ru_RU; 95414346)"
}

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
}


class HttpHelper {
    
    typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    private var session: URLSession
    private var delay: Delay
    private var queue: DispatchQueue
    
    init(urlSession: URLSession, delay: Delay) {
        self.session = urlSession
        self.queue = DispatchQueue.global(qos: .background)
        self.delay = delay
    }
    
    func sendAsync(method: HTTPMethods, url: URL, body: [String: Any], header: [String: String], data: Data? = nil, completion: @escaping completionHandler) {
        queue.asyncAfter(deadline: .now() + delay.random()) {
            var request = self.getDefaultRequest(for: url, method: method)
            self.addHeaders(to: &request, header: header)
            
            if let data = data {
                request.httpBody = data
            } else {
                self.addBody(to: &request, body: body)
            }
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
                completion(data, response as? HTTPURLResponse, error)
            }
            
            task.resume()
        }
    }
    
    fileprivate func getDefaultRequest(for url: URL, method: HTTPMethods) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = method.rawValue
        request.addValue(Headers.HeaderAcceptLanguageValue, forHTTPHeaderField: Headers.HeaderAcceptLanguageKey)
        request.addValue(Headers.HeaderUserAgentValue, forHTTPHeaderField: Headers.HeaderUserAgentKey)
        return request
    }
    
    fileprivate func addHeaders(to request: inout URLRequest, header: [String: String]) {
        if header.count > 0 {
            header.forEach { (key, value) in
                request.allHTTPHeaderFields?.updateValue(value, forKey: key)
            }
        }
    }
    
    fileprivate func addBody(to request: inout URLRequest, body: [String: Any]) {
        if body.count > 0 {
            var queries: [String] = []
            body.forEach { (parameterName, parameterValue) in
                let query = "\(parameterName)=\(parameterValue)"
                queries.append(query)
            }
            
            let data = queries.joined(separator: "&")
            request.httpBody = data.data(using: String.Encoding.utf8)
        }
    }
}
