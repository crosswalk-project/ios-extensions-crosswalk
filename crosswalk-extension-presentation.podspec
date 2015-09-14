# Copyright (c) 2015 Intel Corporation. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

Pod::Spec.new do |s|
  s.name             = 'crosswalk-extension-presentation'
  s.version          = '1.0'
  s.summary          = 'Presentation extension is a Crosswalk extension which implements the W3C Presentation API: http://www.w3.org/TR/presentation-api/'
  s.homepage         = 'https://github.com/crosswalk-project/ios-extensions-crosswalk/tree/master/extensions/Presentation'
  s.license          = { :type => 'BSD', :file => "LICENSE" }
  s.author           = { 'Jonathan Dong' => 'jonathan.dong@intel.com' }
  s.source           = { :git => 'https://github.com/crosswalk-project/ios-extensions-crosswalk.git', :submodules => true }
  s.social_media_url = 'https://twitter.com/xwalk_project'

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.module_name = 'Presentation'
  s.dependency 'crosswalk-ios', '~> 1.1'

  s.source_files = 'extensions/Presentation/Presentation/*.{h,m,swift}'
  s.resource = 'extensions/Presentation/Presentation/*.js', 'extensions/Presentation/Presentation/extensions.plist'

end
