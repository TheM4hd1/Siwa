## Siwa
[![Status](https://img.shields.io/badge/status-Discontinued-critical)](https://github.com/TheM4hd1/SwiftyInsta)  

**Siwa** was a helper framework for [SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta) `1.*`, providing a way to solve some common login issues (e.g. `sentry_block`).
You would need both frameworks to acess all of **Instagram Private API** features.

**[SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta) `2.*` already relies on Siwa's authentication method when using [`Credentials`](https://github.com/TheM4hd1/SwiftyInsta/wiki/Usage)**.

## Installation ##
**Siwa** is compatible with **SwiftyInsta** `1.*` only.  

### CocoaPods ###
```pod 'Siwa'```

#### Create API Handlers ####
```swift
import SwiftyInsta
import Siwa

 // ...

var loginHandler: Siwa.APIHandler
var apiHandler: APIHandlerProtocol

init() {
    loginHandler = try! Siwa.APIBuilder()
                    .setUser(user: Siwa.User(username: "username", password: "password"))
                    .setRequestDelay(delay: .zero)
                    .build()

    apiHandler = try! APIBuilder()
                .createBuilder()
                .setHttpHandler(urlSession: URLSession(configuration: .default))
                .setRequestDelay(delay: DelayModel.init(min: 0, max: 0))
                .setUser(user: SessionStorage.create(username: "username", password: "password"))
                .build()
}
```
---
#### Login ####
```swift
func login() {
    loginHandler.login { (resLogin) in
        if resLogin.isSucceeded {
            if let cookeis = loginHandler.getCookies() {
                let sessionCache = SessionCache.from(cookeis: cookeis)
                apiHandler.login(cache: sessionCache, completion: { (cacheLogin) in
                    if cacheLogin.isSucceeded {
                        // ...
                    } else {
                        // ...
                    }
                }
            }
        } else {
            guard let loginStatus = resLogin.value else { return }
            switch loginStatus {
            case .checkpointRequired:
            // ...
            case .twoFactorRequired:
            // ...
            case .inccorrectPassword, .invalidUsername:
            // ...
            default:
                // ...
            }
        }
    }
}
````
---
#### Handle Challenge ####
```swift
enum VerificationMethod: String {
    case email = "1"
    case sms = "0"
}
```

```swift
// request security code
try loginHandler.sendChallengeVerification(method: .sms, completion: { (resChallenge) in
    guard let challengeStatus = resChallenge.value else { return }
    switch challengeStatus {
        case .codeSent:
            // security code sent to email/sms
        default:
            // failed to send code, probably selected method is wrong.
    }
}

// send security code
try loginHandler.sendChallengeSecurityCode(code: code) { (resChallenge) in
    guard let challengeStatus = resChallenge.value else { return }
    switch challengeStatus {
        case .accepted:
            let cookies = self.loginHandler.getCookies()
            // ...
        case .checkpointDismiss:
            self.loginHandler.loginAfterCheckpointDismissed(completion: { (resDismiss) in
                guard let dismissValue = resDismiss.value else { return }
                switch dismissValue {
                    case .alreadyLoggedIn:
                        let cookies = self.loginHandler.getCookies()
                        // ...
                    case .checkpointLoop:
                        // user needs to trust login via instagram app, then login again
                    case .twoFactorRequired:
                        // a security code sent to user's phonenumber
                        // you need to send security code here.
                    case .default:
                        // ...
                }
            }
        case .incorrect:
            // incorrect challenge security code.
        case default:
            // ...
    }
}
```

#### Handle TwoFactor ####
```swift
let code = "security code or backup code"
try loginHandler.sendTwofactorSecurityCode(code: code, completion: { (resTwofactor) in
    guard let twofactorValue = resTwofactor.value else { return }
    switch twofactorValue {
        case .success:
            let cookies = self.loginHandler.getCookies()
            // ...
        default:
            // ...
    }
}
```
