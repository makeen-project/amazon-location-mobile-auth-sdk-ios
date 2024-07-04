Pod::Spec.new do |s|
  s.platform = :ios, "13.0"
  s.name  = "AmazonLocationiOSAuthSDK"

  s.version      = '0.2.2'
  s.summary      = 'These utilities help you authenticate when when making Amazon Location Service API calls.'
  s.description  = <<-DESC
                      These utilities help you authenticate when when making Amazon Location Service API calls from their iOS applications. This specifically helps when using Amazon Cognito or API keys as the authentication method.
                   DESC
  s.homepage     = 'https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios'
  s.license = { :type => 'Apache License, Version 2.0', :text => 'https://www.apache.org/licenses/LICENSE-2.0' }
  s.author       = { 'Oleg Filimonov' => 'oleg@makeen.io' }
  s.source       = { :git => 'https://github.com/makeen-project/amazon-location-mobile-auth-sdk-ios.git', :branch => 'ALMS-204_CocoaPods_Support' }

  s.ios.deployment_target = '13.0'

  s.source_files  = 'Sources/**/*.{swift,h,m}'
  s.frameworks = 'Foundation'
  s.requires_arc = true

  # Dependencies
   s.dependency 'KeychainSwift', '~> 20.0.0'
   s.spm_dependency "aws-sdk-swift/AWSLocation"
   s.spm_dependency "aws-sdk-swift/AWSCognitoIdentity"
   s.spm_dependency "aws-sdk-swift/AWSClientRuntime"
end
