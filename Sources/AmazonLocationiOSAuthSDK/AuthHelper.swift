import AWSCore
import AWSMobileClientXCF

public class AuthHelper {
    private var newPassword: String?
    
    public init() {
    }
    
    public func setNewPassword(_ newPassword: String) {
        self.newPassword = newPassword
    }
    
    public func authenticateWithCognitoUserPool(identityPoolId: String, region: String) -> LocationCredentialsProvider {
        let regionType = AWSEndpoint.regionTypeByString(regionString: region)
        let credentialProvider : LocationCredentialsProvider = LocationCredentialsProvider(regionType: regionType!, identityPoolId: identityPoolId)
        
        let configuration = AWSServiceConfiguration(
            region: regionType!,
            credentialsProvider: credentialProvider.getCognitoProvider()
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return credentialProvider
    }
    
    public func authenticateWithCognitoUserPool(identityPoolId: String) -> LocationCredentialsProvider {
        let regionType = toRegionType(identityPoolId: identityPoolId)
        
        let credentialProvider : LocationCredentialsProvider = LocationCredentialsProvider(regionType: regionType!, identityPoolId: identityPoolId)
        
        let configuration = AWSServiceConfiguration(
            region: regionType!,
            credentialsProvider: credentialProvider.getCognitoProvider()
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return credentialProvider
    }
    
    public func authenticateWithAPIKey(apiKey: String, region: String) -> LocationCredentialsProvider {
        let credentialProvider = LocationCredentialsProvider(region: region, apiKey: apiKey)
        credentialProvider.setAPIKey(apiKey: apiKey)
        credentialProvider.setRegion(region: region)
        return credentialProvider
    }
    
    public func authenticateWithCognitoUserPool(identityPoolId: String, userPoolId: String, clientId: String, clientSecret: String?, username: String, password: String, completion: @escaping (AWSMobileClientXCF.SignInResult?, Error?) -> Void) ->  LocationCredentialsProvider {
        let regionType = toRegionType(identityPoolId: identityPoolId)
        let credentialProvider : LocationCredentialsProvider = LocationCredentialsProvider(regionType: regionType!, identityPoolId: identityPoolId)

        
        let configuration = AWSServiceConfiguration(
            region: regionType!,
            credentialsProvider: credentialProvider.getCognitoProvider()
        )
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: userPoolId)
        
        AWSCognitoIdentityUserPool.register(with: configuration, userPoolConfiguration: userPoolConfiguration, forKey: "UserPool")
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        configureAWSMobileClient(identityPoolId: identityPoolId, userPoolId: userPoolId, clientId: clientId, clientSecret: clientSecret)
        
        authenticateUser(username: username, password: password, credentialProvider: credentialProvider, completion: completion)
        return credentialProvider
    }

    func configureAWSMobileClient(identityPoolId: String, userPoolId: String, clientId: String, clientSecret: String?) {
        let region = toRegionString(identityPoolId: identityPoolId)
        // Construct the inline JSON configuration
        let configuration: [String: Any] = [
            "IdentityManager": [
                "Default": [:]
            ],
            "CredentialsProvider": [
                "CognitoIdentity": [
                    "Default": [
                        "PoolId": identityPoolId,
                        "Region": region
                    ]
                ]
            ],
            "CognitoUserPool": [
                "Default": [
                    "PoolId": userPoolId,
                    "AppClientId": clientId,
//                    "AppClientSecret": clientSecret ?? "",
                    "Region": region
                ]
            ]
        ]
        
        // Convert the configuration dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: configuration, options: []) else {
            print("Error: Unable to serialize configuration to JSON")
            return
        }
        
        AWSInfo.configureDefaultAWSInfo(configuration)
        
        // Initialize AWSMobileClient with the inline JSON configuration
//        AWSMobileClient.default().initialize(withConfiguration: jsonData) { data in
//            //data
////            if let error = error {
////                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
////            } else if let userState = userState {
////                print("AWSMobileClient initialized. Current UserState: \(userState.rawValue)")
////            }
//        }
        
        AWSMobileClient.default().initialize {(userState, error) in
            // Calling getIdentityId in order to force refresh the AWSMobileClient identityId to the latest one
            //self?.addListener()
            print("AWS login?: \(AWSMobileClient.default().isSignedIn)")
            
            if let userState = userState {
                switch userState {
                case .signedIn:
                    print("Logged In")
                    AWSMobileClient.default().getTokens {tokens, error in
                        print("tokens: \(String(describing: tokens))")
                    }
                default:
                    print("none")
                }
            } else if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func authenticateUser1(username: String, password: String, credentialProvider : LocationCredentialsProvider, completion: @escaping (AWSCognitoIdentityUserSession?, Error?) -> Void) {
        let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        pool?.delegate = self
        let user = pool?.getUser(username)
        
        user?.getSession(username, password: password, validationData: nil).continueWith { (task) -> Any? in
            DispatchQueue.main.async {
                completion(task.result, task.error)
            }
            return nil
        }
    }
    
    
    func authenticateUser(username: String, password: String, credentialProvider : LocationCredentialsProvider, completion: @escaping (AWSMobileClientXCF.SignInResult?, Error?) -> Void) {

        AWSMobileClient.default().signIn(username: username, password: password) { (signInResult, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                } else if let signInResult = signInResult {
                    switch (signInResult.signInState) {
                    case .signedIn:
                        completion(signInResult, nil)
                    default:
                        completion(nil, NSError(domain: "AuthDomain", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Sign In Failed with state: \(signInResult.signInState)"]))
                    }
                }
            }
        }
    }

    public func changePasswordForUser(username: String, currentPassword: String, newPassword: String, completion: @escaping (AWSCognitoIdentityUserChangePasswordResponse?, Error?) -> Void) {
        let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        let user = pool?.getUser(username)
        self.newPassword = newPassword
        user?.changePassword(currentPassword, proposedPassword: newPassword).continueWith { (task) -> Any? in
            DispatchQueue.main.async {
                if let error = task.error {
                    // Handle the error
                    print("Error changing password: \(error.localizedDescription)")
                    completion(nil, task.error)
                } else {
                    // Password change was successful
                    print("Password changed successfully")
                    completion(task.result, task.error)
                }
            }
            return nil
        }
    }
    
    
    private func toRegionType(identityPoolId: String) -> AWSRegionType? {
        var region: AWSRegionType?
    
        if let stringRegion = identityPoolId.components(separatedBy: ":").first {
            
            if let extractedRegion = AWSEndpoint.regionTypeByString(regionString: stringRegion) {
                region = extractedRegion
            } else {
                print("Invalid region: \(stringRegion)")
            }
        }
        return region
    }
    
    private func toRegionString(identityPoolId: String) -> String {
        return identityPoolId.components(separatedBy: ":").first ?? identityPoolId
    }
}

extension AuthHelper: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    public func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    public var hash: Int {
        return 0
    }
    
    public var superclass: AnyClass? {
        return nil
    }
    
    public func `self`() -> Self {
        return self
        
    }
    
    public func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    public func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    public func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }
    
    public func isProxy() -> Bool {
        return false
    }
    
    public func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    public func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    public func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    public func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    public var description: String {
        return ""
    }
    
    public func startNewPasswordRequired() -> AWSCognitoIdentityNewPasswordRequired {
        
        let newPasswordRequiredAuthentication = NewPasswordRequiredImplementation()
        
        newPasswordRequiredAuthentication.setNewPassword(newPassword: newPassword!)
        
        return newPasswordRequiredAuthentication
    }
}


class NewPasswordRequiredImplementation: NSObject, AWSCognitoIdentityNewPasswordRequired {

    var newPassword: String?
    var additionalAttributes: [AWSCognitoIdentityUserAttributeType]? = []
    
    func getNewPasswordDetails(_ newPasswordRequiredInput: AWSCognitoIdentityNewPasswordRequiredInput, newPasswordRequiredCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>) {
        let additionalAttributes: [AWSCognitoIdentityUserAttributeType] = []
        
        let newPasswordDetails = AWSCognitoIdentityNewPasswordRequiredDetails()
        newPasswordDetails.proposedPassword = newPassword!
        newPasswordDetails.userAttributes = additionalAttributes

        newPasswordRequiredCompletionSource.set(result: newPasswordDetails)
    }

    func setNewPassword(newPassword: String) {
        self.newPassword = newPassword
    }
    
    func didCompleteNewPasswordStepWithError(_ error: Error?) {
        if let error = error {
            print("Error completing new password step: \(error)")
        } else {
            print("Successfully completed new password step.")
        }
    }
}
