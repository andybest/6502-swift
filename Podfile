platform :osx, '10.10'

target 'CPU6502Tests' do
  use_frameworks!
  pod 'Nimble', :git => 'https://github.com/Quick/Nimble.git', :branch => 'swift-3.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end