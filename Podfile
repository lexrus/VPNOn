source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def io
  pod 'FileKit', '~> 1.6'
end

def security
  pod 'SwiftKeychainWrapper', :git => 'https://github.com/lexrus/SwiftKeychainWrapper.git'
end

def ui
  pod 'SnapKit', '~> 0.15'
  pod 'RxSwift', '2.0.0-alpha.3'
  pod 'VTAcknowledgementsViewController', '~> 0.15'
end

target 'VPNOn' do
  ui
  io
  security
end

target 'VPNOnTests' do
  io
  security
end

# target 'VPNOnUITests' do
#
# end

target 'TodayWidget' do
  io
  security
end

target 'VPNOnKit' do
  security
end

target 'VPNOnKitTests' do
  security
end
