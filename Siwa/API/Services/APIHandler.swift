//
//  APIHandler.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol APIHandlerProtocols {
    func login(completion: @escaping (Result<IGResponse>) -> ())
    func sendChallengeVerification(method: VerificationMethod, completion: @escaping (Result<VerificationResponse>) -> ()) throws
    func sendChallengeSecurityCode(code: String, completion: @escaping (Result<ChallengeVerificationResponse>) -> ()) throws
    func sendTwofactorSecurityCode(code: String, completion: @escaping (Result<TwofactorVerificationResponse>) -> ()) throws
}

public class APIHandler: APIHandlerProtocols {
    
    private var _httpHelper: HttpHelper
    private var _user: User
    private var _checkpointUrl: String?
    private var _twoFactor: TwoFactorInfo?
    private var _loggedInUser: LoggedInUser?
    
    public init(user: User, urlSession: URLSession, delay: Delay) throws {
        self._httpHelper = HttpHelper(urlSession: urlSession, delay: delay)
        self._user = user
        try validateUser()
    }
    
    public func login(completion: @escaping (Result<IGResponse>) -> ()) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        _httpHelper.sendAsync(method: .get, url: URLs.home(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                print(error)
                completion(Return.fail(error: error, rawData: data, value: nil))
            } else {
                self.getCsrftoken(from: response)
                let headers = ["X-Instagram-AJAX": "1",
                               "X-CSRFToken": self._user.csrftoken,
                               "X-Requested-With": "XMLHttpRequest",
                               "Referer": "https://instagram.com/"]
                
                let body = ["username": self._user.username,
                            "password": self._user.password,
                ]
                
                self._httpHelper.sendAsync(method: .post, url: URLs.login(), body: body, header: headers, completion: { (data, res, err) in
                    if let error = err {
                        completion(Return.fail(error: error, rawData: data, value: nil))
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                let result = try decoder.decode(LoginResponse.self, from: data)
                                if let checkpointUrl = result.checkpointUrl {
                                    print(checkpointUrl)
                                    self._checkpointUrl = checkpointUrl
                                    completion(Return.fail(error: nil, rawData: data, value: .checkpointRequired))
                                } else if let twoFactor = result.twoFactorInfo {
                                    self._twoFactor = twoFactor
                                    completion(Return.fail(error: nil, rawData: data, value: .twoFactorRequired))
                                } else if let authentication = result.authenticated {
                                    if authentication {
                                        self._user.id = result.userId!
                                        completion(Return.success(value: .success, rawData: data))
                                    } else if result.user ?? false {
                                        completion(Return.fail(error: nil, rawData: data, value: .wrongPassword))
                                    } else {
                                        completion(Return.fail(error: nil, rawData: data, value: .wrongUsername))
                                    }
                                } else {
                                    completion(Return.fail(error: nil, rawData: data, value: .unknwon))
                                }
                                
                            } catch {
                                completion(Return.fail(error: err, rawData: data, value: nil))
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    
    public func sendChallengeVerification(method: VerificationMethod, completion: @escaping (Result<VerificationResponse>) -> ()) throws {
        if let checkpointUrl = _checkpointUrl {
            let _url = URLs.checkpoint(url: checkpointUrl)
            let body = ["choice": method.rawValue]
            let headers = ["X-CSRFToken": _user.csrftoken,
                        "X-Requested-With": "XMLHttpRequest",
                        "Referer": _url.absoluteString,
                        "X-Instagram-AJAX": "1"]
            
            _httpHelper.sendAsync(method: .post, url: _url, body: body, header: headers) { (data, response, err) in
                if let error = err {
                    completion(Return.fail(error: error, rawData: data, value: .failed))
                } else {
                    if let data = data {
                        let stringData = String(data: data, encoding: .utf8)!
                        if stringData.contains("Enter the 6-digit code") || stringData.contains("Enter Your Security Code")  || stringData.contains("VerifySMSCodeForm") || stringData.contains("VerifyEmailCodeForm") {
                            completion(Return.success(value: .codeSent, rawData: data))
                        } else {
                            completion(Return.fail(error: nil, rawData: data, value: .unknown))
                        }
                    }
                }
            }
        } else {
            throw SiwaErrors.checkpointNotfound
        }
    }
    
    public func sendChallengeSecurityCode(code: String, completion: @escaping (Result<ChallengeVerificationResponse>) -> ()) throws {
        if let checkpointUrl = _checkpointUrl {
            let _url = URLs.checkpoint(url: checkpointUrl)
            let body = ["security_code": code]
            let headers = ["X-CSRFToken": _user.csrftoken,
                           "X-Requested-With": "XMLHttpRequest",
                           "Referer": _url.absoluteString,
                           "X-Instagram-AJAX": "1"]
            
            _httpHelper.sendAsync(method: .post, url: _url, body: body, header: headers) { (data, response, error) in
                if let error = error {
                    completion(Return.fail(error: error, rawData: data, value: .unknown))
                } else {
                    if response?.statusCode == 200 {
                        let stringData = String(data: data!, encoding: .utf8)!
                        print(stringData)
                        if stringData.contains("CHALLENGE_REDIRECTION") {
                            if stringData.contains("instagram://checkpoint/dismiss") {
                                completion(Return.success(value: .checkpointDismiss, rawData: data))
                            } else {
                                completion(Return.success(value: .accepted, rawData: data))
                            }
                        } else {
                            completion(Return.fail(error: nil, rawData: data, value: .noRedirect))
                        }
                    } else {
                        completion(Return.fail(error: nil, rawData: data, value: .incorrect))
                    }
                }
            }
        } else {
            throw SiwaErrors.checkpointNotfound
        }
    }
    
    public func sendTwofactorSecurityCode(code: String, completion: @escaping (Result<TwofactorVerificationResponse>) -> ()) throws {
        if let twoFactor = _twoFactor {
            let _url = URLs.twoFactor()
            let body = ["username": _user.username,
                        "verificationCode": code,
                        "identifier": twoFactor.twoFactorIdentifier!]
            let headers = ["X-CSRFToken": _user.csrftoken,
                           "X-Requested-With": "XMLHttpRequest",
                           "Referer": _url.absoluteString,
                           "X-Instagram-AJAX": "1"]
            
            _httpHelper.sendAsync(method: .post, url: _url, body: body, header: headers) { (data, response, error) in
                if let error = error {
                    completion(Return.fail(error: error, rawData: data, value: .failed))
                } else {
                    if let data = data {
                        if response?.statusCode == 200 {
                            completion(Return.success(value: .success, rawData: data))
                        } else if response?.statusCode == 400 {
                            completion(Return.fail(error: nil, rawData: data, value: .invalidCode))
                        } else {
                            completion(Return.fail(error: nil, rawData: data, value: .unknown))
                        }
                    }
                }
            }
        } else {
            throw SiwaErrors.twofactorNotfound
        }
    }
    
    public func loginAfterCheckpointDismissed(completion: @escaping (Result<IGResponse>) -> ()) {
        let headers = ["X-Instagram-AJAX": "1",
                       "X-CSRFToken": self._user.csrftoken,
                       "X-Requested-With": "XMLHttpRequest",
                       "Referer": "https://instagram.com/"]
        
        let body = ["username": self._user.username,
                    "password": self._user.password,
        ]
        
        _httpHelper.sendAsync(method: .post, url: URLs.login(), body: body, header: headers) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, rawData: data, value: .unknwon))
            } else {
                if let data = data {
                    let stringData = String(data: data, encoding: .utf8)!
                    if stringData.contains("two_factor_required") {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let res = try! decoder.decode(LoginResponse.self, from: data)
                        self._twoFactor = res.twoFactorInfo
                        completion(Return.success(value: .twoFactorRequired, rawData: data))
                    } else {
                        if stringData.contains("checkpoint_required") {
                            completion(Return.fail(error: nil, rawData: data, value: .checkpointLoop))
                        } else {
                            completion(Return.success(value: .alreadyLoggedIn, rawData: data))
                        }
                    }
                } else {
                    completion(Return.fail(error: nil, rawData: data, value: .nilData))
                }
            }
        }
    }
}

// MARK: - Public Helper Functions
extension APIHandler {
    public func getCookies() -> [Data]? {
        return HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData()
    }
    
    public func getLoggedInUser() -> LoggedInUser? {
        return self._loggedInUser
    }
    
    public func getTwoFactorInfo() -> TwoFactorInfo? {
        return self._twoFactor
    }
    
    public func getChallengeInfo(completion: @escaping (ChallengeForm?) -> ()) {
        if let checkpointUrl = _checkpointUrl {
            let _url = URLs.checkpoint(url: checkpointUrl)
            
            _httpHelper.sendAsync(method: .get, url: _url, body: [:], header: [:]) { (data, response, error) in
                if let data = data {
                    let stringData = String(data: data, encoding: .utf8)!
                    if stringData.contains("window._sharedData = ") {
                        let dataPartOne = stringData.components(separatedBy: "window._sharedData = ")[1]
                        let rawData = dataPartOne.components(separatedBy: ";</script>")[0]
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let checkpointData = try! decoder.decode(ChallengeForm.self, from: rawData.data(using: .utf8)!)
                        completion(checkpointData)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
}

// MARK: - Private Helper Functions
extension APIHandler {
    fileprivate func getCsrftoken(from response: HTTPURLResponse?) {
        let responseHeaderFields = response?.allHeaderFields as! [String: String]
        let responseUrl = (response?.url)!
        let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: responseHeaderFields, for: responseUrl)
        
        for cookie in responseCookies {
            if cookie.name == "csrftoken" {
                print(cookie.value)
                _user.csrftoken = cookie.value
                break
            }
        }
    }
    
    fileprivate func validateUser() throws {
        if _user.username.isEmpty {
            throw SiwaErrors.usernameRequired
        }
        
        if _user.password.isEmpty {
            throw SiwaErrors.passwordRequired
        }
    }
}

extension Array where Element: HTTPCookie {
    func toCookieData() -> [Data] {
        var cookies = [Data]()
        for cookie in self {
            if let cookieData = cookie.convertToData() {
                cookies.append(cookieData)
            }
        }
        
        return cookies
    }
    
    func getInstagramCookies() -> [HTTPCookie]? {
        if let cookies = HTTPCookieStorage.shared.cookies(for: URLs.home()) {
            return cookies
        }
        
        return [HTTPCookie]()
    }
}

extension HTTPCookie {
    fileprivate func save(cookieProperties: [HTTPCookiePropertyKey : Any]) -> Data {
        let data = NSKeyedArchiver.archivedData(withRootObject: cookieProperties)
        return data
    }
    
    static fileprivate func loadCookieProperties(from data: Data) -> [HTTPCookiePropertyKey : Any]? {
        let unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: data)
        return unarchivedDictionary as? [HTTPCookiePropertyKey : Any]
    }
    
    static func loadCookie(using data: Data?) -> HTTPCookie? {
        guard let data = data, let properties = loadCookieProperties(from: data) else {
            return nil
        }
        
        return HTTPCookie(properties: properties)
    }
    
    func convertToData() -> Data? {
        guard let properties = self.properties else {
            return nil
        }
        
        return save(cookieProperties: properties)
    }
}
