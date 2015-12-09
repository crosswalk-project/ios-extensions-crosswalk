// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ViewController.h"

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <XWalkView/XWalkView.h>
#import <XWalkView/XWalkView-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  NSString* start_url = @"index.html";
  NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"manifest"
                                                        ofType:@"plist"];
  NSDictionary* manifest =
      [NSDictionary dictionaryWithContentsOfFile:plistPath];
  start_url = [manifest valueForKey:@"start_url"];

  WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
  webView_ = [[XWalkView alloc] initWithFrame:self.view.frame
                                configuration:configuration];
  webView_.scrollView.bounces = false;
  [self.view addSubview:webView_];

  id extension = [XWalkExtensionFactory createExtension:@"navigator.iap"];
  [webView_ loadExtension:extension namespace:@"navigator.iap"];
  NSURL* root = [[NSBundle mainBundle].resourceURL
      URLByAppendingPathComponent:@"www"];
  NSURL* url = [root URLByAppendingPathComponent:start_url];
  [webView_ loadFileURL:url allowingReadAccessToURL:root];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
