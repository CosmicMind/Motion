Pod::Spec.new do |s|
  s.name = 'Motion'
  s.version = '1.0.0'
  s.license = 'BSD-3-Clause'
  s.summary = 'Seamless animations and transitions in Swift.'
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
