Pod::Spec.new do |s|
  s.name             = "RACMutableCollectionProperty"
  s.version          = "0.0.2"
  s.summary          = "MutableCollectionProperty for ReactiveCocoa"
  s.homepage         = "https://github.com/gitdoapp/RAC-MutableCollectionProperty"
  s.license          = 'MIT'
  s.author           = { "@pepibumur" => "pepibumur@gmail.com" }
  s.source           = { :git => "https://github.com/gitdoapp/RAC-MutableCollectionProperty.git", :tag => s.version.to_s }

  s.tvos.deployment_target = '9.0'
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.requires_arc = true

  s.source_files = 'MutableCollectionProperty/**/*.swift'
  s.dependency 'ReactiveCocoa', '4.0.1'
end
