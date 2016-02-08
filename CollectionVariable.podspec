Pod::Spec.new do |s|
  s.name             = "CollectionVariable"
  s.version          = "0.0.1"
  s.summary          = "CollectionVariable for RxSwift"
  s.homepage         = "https://github.com/gitdoapp/CollectionVariable"
  s.license          = 'MIT'
  s.author           = { "@pepibumur" => "pepibumur@gmail.com" }
  s.source           = { :git => "https://github.com/gitdoapp/CollectionVariable.git", :tag => s.version.to_s }

  s.tvos.deployment_target = '9.0'
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.requires_arc = true

  s.source_files = 'CollectionVariable/**/*.swift'
  s.dependency 'RxSwift', '~> 2.1'
end
