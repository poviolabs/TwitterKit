Pod::Spec.new do |s|
  s.name = "TwitterCore"
  s.version = "3.2.1"
  s.summary = "Increase user engagement and app growth."
  s.homepage = "https://github.com/poviolabs/TwitterKit"
  s.documentation_url = "https://github.com/poviolabs/TwitterKit/wiki"
  s.social_media_url = "https://twitter.com/poviolabs"
  s.authors = "Twitter, Povio Labs"
  s.platforms = { :ios => "9.0", :tvos => "9.0" }
  s.source = { :http => "https://github.com/poviolabs/TwitterKit/releases/download/v#{s.version}-TC/TwitterCore.zip" }
  s.license = { :type => "Commercial", :text => "Copyright Twitter, Inc. All Rights Reserved. Use of this software is subject to the terms and conditions of the Twitter Kit Agreement located at https://dev.twitter.com/overview/terms/twitterkit and the Developer Agreement located at https://dev.twitter.com/overview/terms/agreement. OSS: https://github.com/twitter/twitter-kit-ios/blob/master/OS_LICENSES.md" }
  s.preserve_paths = "iOS/TwitterCore.framework/"
  s.xcconfig = {
	  'FRAMEWORK_SEARCH_PATH[sdk=iphoneos*]' => '$(inherited) "$(PODS_ROOT)/iOS/TwitterCore"',
	  'OTHERCFLAGS[sdk=iphoneos*]' => '$(inherited) -iframework "$(PODS_ROOT)/iOS/TwitterCode"',
	  'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework iOS/TwitterCore'
  }
  s.ios.frameworks = "Accounts", "CoreData", "CoreGraphics", "Foundation", "Security", "Social", "UIKit"
  s.tvos.frameworks = "CoreData", "CoreGraphics", "Foundation", "Security", "UIKit"
end
