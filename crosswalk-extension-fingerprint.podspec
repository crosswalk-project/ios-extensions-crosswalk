# Copyright (c) 2016 Intel Corporation. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

Pod::Spec.new do |s|
  s.name             = 'crosswalk-extension-fingerprint'
  s.version          = '1.3'
  s.summary          = 'Fingerprint extension is a Crosswalk extension which implements touchID authentication on iOS'
  s.homepage         = 'https://github.com/crosswalk-project/ios-extensions-crosswalk/tree/master/extensions/Fingerprint'
  s.license          = { :type => 'BSD', :file => "LICENSE" }
  s.author           = { 'Minggang Wang' => 'minggang.wang@intel.com' }
  s.source           = { :git => 'https://github.com/crosswalk-project/ios-extensions-crosswalk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/xwalk_project'

  s.platform = :ios, '8.1'
  s.ios.deployment_target = '8.1'
  s.module_name = 'Fingerprint'
  s.dependency 'crosswalk-ios', '~> 1.2'

  s.source_files = 'extensions/Fingerprint/Fingerprint/*.{h,m,swift}'
  s.resource = 'extensions/Fingerprint/Fingerprint/*.js', 'extensions/Fingerprint/Fingerprint/extensions.plist'

end
