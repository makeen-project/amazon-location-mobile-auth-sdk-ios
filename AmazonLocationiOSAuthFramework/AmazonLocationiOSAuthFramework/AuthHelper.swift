import Foundation
import AmazonLocationiOSAuthSDK

@objc public class AuthHelper: NSObject {

    private var locationCredentialsProvider: LocationCredentialsProvider?
    private var authHelper: AmazonLocationiOSAuthSDK.AuthHelper
    
    @objc public override init() {
        authHelper = AmazonLocationiOSAuthSDK.AuthHelper()
    }
    
    @objc public func authenticateWithCognitoIdentityPool(identityPoolId: String) async throws -> LocationCredentialsProvider? {
        return try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId)
    }
    
    @objc public func authenticateWithCognitoIdentityPool(identityPoolId: String, region: String) async throws -> LocationCredentialsProvider? {
        return try await authHelper.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId, region: region)
    }

    @objc public func authenticateWithApiKey(apiKey: String, region: String) -> LocationCredentialsProvider {
        return authHelper.authenticateWithApiKey(apiKey: apiKey, region: region)
    }
    
    @objc public func authenticateWithCredentialsProvider(credentialsProvider: AmazonLocationCustomCredentialsProvider, region: String) async throws -> LocationCredentialsProvider? {
        return try await authHelper.authenticateWithCredentialsProvider(credentialsProvider: credentialsProvider, region: region)
    }
    
    @objc public func getLocationClient() -> AmazonLocationClient? {
        if let client = authHelper.getLocationClient() {
            return AmazonLocationClient(amazonLocationClient: client)
        }
        return nil
    }
}

