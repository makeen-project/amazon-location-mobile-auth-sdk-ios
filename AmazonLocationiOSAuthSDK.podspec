Pod::Spec.new do |s|
  s.name         = 'AmazonLocationiOSAuthSDK'
  s.version      = '0.2.2'
  s.summary      = 'These utilities help you authenticate when when making Amazon Location Service API calls from their iOS applications. This specifically helps when using Amazon Cognito or API keys as the authentication method.'
  s.description  = <<-DESC
                    A more detailed description of MyPackage.
                   DESC
  s.homepage     = 'https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios'
  s.license = { :type => 'Apache License, Version 2.0', :text => 'https://www.apache.org/licenses/LICENSE-2.0' }
  s.author       = { 'Oleg Filimonov' => 'oleg@makeen.io' }
  s.source       = { :git => 'https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios/.git', :tag => 0.2.2 }

  s.ios.deployment_target = '13.0'

  s.source_files  = 'Sources/**/*.{swift,h,m}'
  s.public_header_files = 'Sources/**/*.h'
  s.frameworks = 'Foundation'
  s.requires_arc = true

  # Dependencies
  s.dependency 'KeychainSwift', '~> 20.0.0'
  s.dependency 'AWSLocation', :git => 'https://github.com/awslabs/aws-sdk-swift', :branch => '0.46.0'
  s.dependency 'AWSCognitoIdentity', :git => 'https://github.com/awslabs/aws-sdk-swift', :branch => '0.46.0'
  s.dependency 'AWSClientRuntime', :git => 'https://github.com/awslabs/aws-sdk-swift', :branch => '0.46.0'

  # Test target resources
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift,h,m}'
    test_spec.resources = ['Tests/Resources/TestConfig.plist']
  end
end
