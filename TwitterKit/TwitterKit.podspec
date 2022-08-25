Pod::Spec.new do |s|
  s.name = "TwitterKit"
  s.version = "3.4.4"
  s.summary = "Increase user engagement and app growth."
  s.homepage = "https://github.com/poviolabs/TwitterKit"
  s.documentation_url = "https://github.com/poviolabs/TwitterKit/wiki"
  s.social_media_url = "https://twitter.com/poviolabs"
  s.authors = "Twitter"
  s.platform = :ios, "9.0"
  s.source = { :http => "https://github.com/poviolabs/TwitterKit/releases/download/v#{s.version}-TK/TwitterKit.zip" }
  s.preserve_paths = "iOS/TwitterKit.framework/"
  s.xcconfig = {
	  'FRAMEWORK_SEARCH_PATH[sdk=iphoneos*]' => '$(inherited) "$(PODS_ROOT)/iOS/TwitterKit"',
	  'OTHERCFLAGS[sdk=iphoneos*]' => '$(inherited) -iframework "$(PODS_ROOT)/iOS/TwitterKit"',
	  'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework iOS/TwitterKit'
  }
  s.license = { :type => "Commercial", :text => "Twitter Kit: Copyright Twitter, Inc. All Rights Reserved. Use of this software is subject to the terms and conditions of the Twitter Kit Agreement located at https://dev.twitter.com/overview/terms/twitterkit and the Developer Agreement located at https://dev.twitter.com/overview/terms/agreement. OSS: https://github.com/twitter/twitter-kit-ios/blob/master/OS_LICENSES.md"}
  s.resources = ["iOS/TwitterKit.framework/TwitterKitResources.bundle", "iOS/TwitterKit.framework/TwitterShareExtensionUIResources.bundle"]
  s.frameworks = "CoreText", "QuartzCore", "CoreData", "CoreGraphics", "Foundation", "Security", "UIKit", "CoreMedia", "AVFoundation", "SafariServices"
  s.dependency "TwitterCore", ">= 3.2.1"
end
