# Podfile - BuilderOS iOS App
# CocoaPods dependency management

platform :ios, '17.0'
use_frameworks!

target 'BuilderSystemMobile' do
  # Tailscale iOS SDK
  # Documentation: https://tailscale.com/kb/1114/ios-sdk
  pod 'Tailscale', '~> 1.88.0'

  # Note: Tailscale SDK is currently only available via CocoaPods
  # Once integrated, the app will have:
  # - Tailscale VPN connection management
  # - Device discovery on Tailscale network
  # - OAuth authentication flow
  # - End-to-end encrypted connections
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
