Pod::Spec.new do |s|
  s.name             = 'LuqtaSDK'
  s.version          = '1.5.0'
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
- Geolocation / AR treasure-hunt levels (8th Wall engine bundled)
- Survey, link-task, referral and QR auto-completion levels
  DESC
  s.homepage         = 'https://github.com/FaziiHamza/luqta-ios-sdk'
  s.license          = { :type => 'MIT', :text => <<-LICENSE
MIT License

Copyright (c) 2025 Luqta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE
  }
  s.author           = { 'Luqta' => 'support@luqta.com' }
  s.source           = { :http => 'https://github.com/FaziiHamza/luqta-ios-sdk/releases/download/1.5.0/LuqtaSDK.xcframework.zip' }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'
  s.vendored_frameworks = 'LuqtaSDK.xcframework'
  # Matches the source podspec: WebKit runs the AR scene and the link-task
  # page, CoreLocation and MapKit the geolocation hunt.
  s.frameworks = 'Foundation', 'Security', 'AVFoundation', 'UIKit', 'SwiftUI',
                 'WebKit', 'CoreLocation', 'MapKit', 'Network'
end
