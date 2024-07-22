
import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation


@objc public class AmazonLocationClient: NSObject {
    public let locationProvider: LocationCredentialsProvider
    public var locationClient: LocationClient?
    
    private var amazonLocationClient: AmazonLocationiOSAuthSDK.AmazonLocationClient
    
    @objc public init(locationCredentialsProvider: LocationCredentialsProvider) {
        amazonLocationClient = AmazonLocationiOSAuthSDK.AmazonLocationClient(locationCredentialsProvider: locationCredentialsProvider)
        self.locationProvider = locationCredentialsProvider
        self.locationClient = amazonLocationClient.locationClient
    }
    
    @objc internal init(amazonLocationClient: AmazonLocationiOSAuthSDK.AmazonLocationClient) {
        self.locationProvider = amazonLocationClient.locationProvider
        self.amazonLocationClient = amazonLocationClient
        self.locationClient = amazonLocationClient.locationClient
    }
    
}
