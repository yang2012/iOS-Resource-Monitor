Pod::Spec.new do |s|
  s.name             = "iOSResourceMonitor"
  s.version          = "0.0.1"
  s.summary          = "iOS网络请求监控"
  s.description      = <<-DESC
iOS网络请求监控
                       DESC
  s.homepage         = "https://github.com/yang2012/iOS-Resource-Monitor"
  s.license          = 'Apache License'
  s.author           = { "Justin Yang" => "justin.yang2012@gmail.com" }
  s.source           = { :git => "https://github.com/yang2012/iOS-Resource-Monitor.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/*.{h,m}'
  s.resources    = 'Pod/Assets/*'
  s.libraries = 'z'
end
