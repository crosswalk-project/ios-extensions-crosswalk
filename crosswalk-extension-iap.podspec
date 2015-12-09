# Copyright (c) 2015 Intel Corporation. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

Pod::Spec.new do |s|
  s.name             = 'crosswalk-extension-iap'
  s.version          = '1.0'
  s.summary          = 'IAP extension is a Crosswalk extension which implements the in-app purchase on iOS'
  s.homepage         = 'https://github.com/crosswalk-project/ios-extensions-crosswalk/tree/master/extensions/IAP'
  s.license          = { :type => 'BSD', :file => "LICENSE" }
  s.author           = { 'Minggang Wang' => 'minggang.wang@intel.com' }
  s.source           = { :git => 'https://github.com/crosswalk-project/ios-extensions-crosswalk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/xwalk_project'

  s.platform = :ios, '8.1'
  s.ios.deployment_target = '8.1'
  s.module_name = 'IAP'
  s.dependency 'crosswalk-ios', '~> 1.2'

  s.source_files = 'extensions/IAP/IAP/*.{h,m,swift}'
  s.resource = 'extensions/IAP/IAP/*.js', 'extensions/IAP/IAP/extensions.plist'

end