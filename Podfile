# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Lulu' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Lulu
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'AlamofireImage', '~> 3.1'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'SZTextView'
  pod 'JSQMessagesViewController'
  pod 'M13Checkbox'

  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

  target 'LuluTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LuluUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Ensures that GeoFire is linked with FirebaseData
# See: https://github.com/firebase/geofire-objc/issues/48#issuecomment-257217532
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'GeoFire' then
      target.build_configurations.each do |config|
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] = "#{config.build_settings['FRAMEWORK_SEARCH_PATHS']} ${PODS_ROOT}/FirebaseDatabase/Frameworks/ $PODS_CONFIGURATION_BUILD_DIR/GoogleToolboxForMac"
        config.build_settings['OTHER_LDFLAGS'] = "#{config.build_settings['OTHER_LDFLAGS']} -framework FirebaseDatabase"
      end
    end
  end
end
