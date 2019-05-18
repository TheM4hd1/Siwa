### About Siwa ###
**Siwa** is a helper framework for [SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta) to solve login problems such as ```sentry_block``` error.

You need to combine these two frameworks to use all available features in ```Instagram API```

use ```loginHandler``` to request login authentication and use ```apiHandler``` to do other requests such as ```like, follow, comment, receiving medias or ...```

## Installation ##
### CocoaPods ###
```pod 'Siwa'```

### Manually ###
To use this library in your project manually you may: 
- Add compiled framework from ```General > Linked frameworks and libraries ```
- Clone the project, right click on your root project and select Add files..., then select the ```Siwa.xcodeproj```. 
after that go to your ```project > embeded libraries``` and select ```Siwa.framework```, build the project and import ```Siwa```


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
