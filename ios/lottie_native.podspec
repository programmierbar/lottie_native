#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint lottie_native.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'lottie_native'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of lottie_native'
  s.homepage         = 'https://github.com/lotum/lottie_native'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lotum' => '' }

  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*'

  s.dependency 'Flutter'
  s.dependency 'lottie-ios', '~> 4.2.0'

  s.platform            = :ios, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version       = '5.0'
end

