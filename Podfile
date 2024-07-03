platform :ios, "13.0"

plugin "cocoapods-spm"

target 'AmazonLocationiOSAuthSDK' do

  spm_pkg "aws-sdk-swift", :git => "https://github.com/awslabs/aws-sdk-swift.git", :tag => "0.46.0",
     :products => ["AWSLocation", "AWSCognitoIdentity", "AWSClientRuntime"]

end
