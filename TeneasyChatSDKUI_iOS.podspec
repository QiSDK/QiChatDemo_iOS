#
# Be sure to run `pod lib lint TeneasyChatSDKUI_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TeneasyChatSDKUI_iOS'
  s.version          = '1.0.5'
  s.summary          = 'A short description of TeneasyChatSDKUI_iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/QiSDK/QiChatDemo_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '7938813' => 'xiaofu2024@gmail.com' }
  s.source           = { :git => 'https://github.com/QiSDK/QiChatDemo_iOS', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'TeneasyChatSDKUI_iOS/Classes/**/*'
  
  # s.resource_bundles = {
   #  'TeneasyChatSDKUI_iOS' => ['TeneasyChatSDKUI_iOS/Assets/png/*.png', 'TeneasyChatSDKUI_iOS/Assets/emoticon/*.gif']
   #}
   
   s.resource_bundles = {
     'TeneasyChatSDKUI_iOS' => ['TeneasyChatSDKUI_iOS/Assets/**/*','TeneasyChatSDKUI_iOS/Assets/svg/*', 'TeneasyChatSDKUI_iOS/Assets/png/*.png', 'TeneasyChatSDKUI_iOS/Assets/emoticon/*.gif']
   }
   
   #s.resources = "Resources/**/*.{png,storyboard}" //for storyboard and png files

#   s.public_header_files = 'TeneasyChatSDKUI_iOS/Classes/xclient.framework/**/*.h'
   s.frameworks = 'UIKit'#, 'MapKit'
   s.dependency 'TeneasyChatSDK_iOS'
   s.dependency 'SnapKit', '~> 5.0.1'
   s.dependency 'IQKeyboardManagerSwift', '~> 6.5.9'
   s.dependency 'SwiftDate', '~> 6.3.1'
   s.dependency 'Kingfisher', '~> 6.3.1'
   s.dependency 'Alamofire', '~> 5.4.4'
   s.dependency 'SVGKit'
   s.dependency 'Moya', '~> 15.0.0'
   s.dependency 'HandyJSON', '~> 5.0.2'
   s.dependency 'SVProgressHUD', '~> 2.2.5'
   s.dependency 'Toast-Swift', '~> 5.0.0'
   s.dependency 'XMMenuPopover'
 
end
