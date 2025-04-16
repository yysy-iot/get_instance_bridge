#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint get_instance_bridge.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'get_instance_bridge'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin bridge.'
  s.description      = <<-DESC
A plugin bridge for managing instances.
                       DESC
  s.homepage         = 'https://github.com/yysy-iot'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'YueYing Industry' => 'charlie@yueying-industry.com' }

  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*'
  # ✅ 平台设置
  s.platform = :ios, '12.0'
  # ✅ 依赖
  s.ios.dependency 'Flutter'
  s.dependency 'instance_bridge_core', '~> 0.0.4'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  # ✅ Swift 支持（如果有 Swift 文件）
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'get_instance_bridge_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
