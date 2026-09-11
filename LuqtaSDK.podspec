Pod::Spec.new do |s|
  s.name             = 'LuqtaSDK'
  s.version          = '1.4.0'
  s.summary          = 'Official iOS SDK for Luqta API with pre-configured UI'
  s.description      = <<-DESC
The official iOS SDK for Luqta API. Provides a complete pre-configured SwiftUI UI
and a comprehensive interface for interacting with the Luqta backend.

Features:
- Pre-configured SwiftUI UI (contests, levels, quizzes)
- Flexible user identification (email OR phone number)
- Automatic validation of email and phone formats
- Keychain storage for authentication tokens
- QR code scanning and image upload
- Full async/await support
- RTL and localization support (EN/AR)
  DESC
  s.homepage         = 'https://github.com/MTayyaBH/luqta-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luqta' => 'support@luqta.com' }
  s.source           = { :http => 'https://github.com/MTayyaBH/luqta-ios-sdk/releases/download/1.4.0/LuqtaSDK.xcframework.zip' }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'
  s.vendored_frameworks = 'LuqtaSDK.xcframework'
  s.frameworks = 'Foundation', 'Security', 'AVFoundation', 'UIKit', 'SwiftUI'
end
