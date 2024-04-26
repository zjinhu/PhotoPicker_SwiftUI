#
# Be sure to run `pod lib lint PhotoPicker_SwiftUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhotoPicker_SwiftUI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PhotoPicker_SwiftUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/hu/PhotoPicker_SwiftUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hu' => '' }
  s.source           = { :git => 'https://github.com/hu/PhotoPicker_SwiftUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = "14.0" 
  s.swift_version = "5.0"
  #s.swift_versions = ['5.5','5.4','5.3','5.2','5.1','5.0']
  s.requires_arc = true
  #s.frameworks   = "UIKit", "Foundation", "SwiftUI" #支持的框架
  
  s.source_files = 'Sources/PhotoPicker_SwiftUI/**/*'
  
  #文件路径
  #s.subspec 'In' do |ss|
  #  ss.source_files = 'Code/*.swift'
  #end
  
  #资源包
  #s.resource_bundles = {
  #  'PhotoPicker_SwiftUI' => ['Sources/Resource/**/*']
  #}

  # s.dependency 'SwiftBrick', '~> 2.4.0'
end
