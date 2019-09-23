Pod::Spec.new do |s|
  s.name = 'Motion'
  s.version = '3.1.3'
  s.swift_version = '5.0'
  s.license = 'MIT'
  s.summary = 'A library used to create beautiful animations and transitions for iOS.'
  s.homepage = 'http://cosmicmind.com'
  s.social_media_url = 'https://www.facebook.com/cosmicmindcom'
  s.authors = { 'CosmicMind, Inc.' => 'support@cosmicmind.com' }
  s.source = { :git => 'https://github.com/CosmicMind/Motion.git', :tag => s.version }
  s.platform = :ios, '8.0'
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |s|
    s.ios.deployment_target = '8.0'
    s.ios.source_files = 'Sources/**/*.swift'
    s.requires_arc = true
  end
end
