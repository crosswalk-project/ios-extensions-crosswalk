# Copyright (c) 2015 Intel Corporation. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

Pod::Spec.new do |s|
  s.name             = 'crosswalk-extension-cordova'
  s.version          = '1.0'
  s.summary          = 'Cordova extension is a Crosswalk extension which enables Cordova plugins to integrate with Crosswalk runtime. With this extension you can leverage the existing Cordova plugins to build up your Crosswalk application for iOS.'
  s.homepage         = 'https://github.com/crosswalk-project/ios-extensions-crosswalk'
  s.license          = { :type => 'BSD', :file => "LICENSE" }
  s.author           = { 'Jonathan Dong' => 'jonathan.dong@intel.com' }
  s.source           = { :git => 'https://github.com/crosswalk-project/ios-extensions-crosswalk.git', :submodules => true }
  s.social_media_url = 'https://twitter.com/xwalk_project'

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.module_name = 'Cordova'
  s.dependency 'crosswalk-ios', '~> 1.1'

  s.source_files =['extensions/Cordova/Cordova/*.{h,m,swift}',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVAvail*.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVCommandDelegate.h',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVCommandQueue.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVInvoked*.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVPlugin.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDVPluginResult.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/CDV[S,T,U,W]*.*',
        'third-party/cordova-ios/CordovaLib/Classes/Public/NS*.*',
        'third-party/cordova-ios/CordovaLib/Classes/Private/*.{h,m}',
        'third-party/cordova-ios/CordovaLib/Classes/Private/**/*.{h,m}']
  s.resource = 'extensions/Cordova/Cordova/*.js', 'extensions/Cordova/Cordova/extensions.plist'

end
