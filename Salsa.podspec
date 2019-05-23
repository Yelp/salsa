Pod::Spec.new do |s|
  s.name             = 'Salsa'
  s.version          = '0.7.0'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'Salsa is a tool for generating Sketch files out of iOS UI elements'
  s.homepage         = 'https://github.com/Yelp/salsa'
  s.authors          = { 'Yelp iOS Team' => 'iphone@yelp.com' }
  s.source           = { :git => "https://github.com/Yelp/salsa.git", :tag => 'v' + s.version.to_s }

  s.platform     = :ios, '9.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
  s.source_files = 'Shared/*.swift'
  s.ios.source_files = 'Salsa/**/*.{m,h,swift}'
  s.swift_version = '4.0'
end
