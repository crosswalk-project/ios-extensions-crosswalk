// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ReceiptHelper.h"

#import <StoreKit/StoreKit.h>

#define VALIDATION_SANDBOX_URL @"https://sandbox.itunes.apple.com/verifyReceipt"
#define VALIDATION_PRODUCTION_URL @"https://buy.itunes.apple.com/verifyReceipt"

@interface ReceiptHelper(Private)

- (NSData*)getStoreReceipt;
- (void)refreshReceipt;
- (void)doValidation:(NSData*)receipt;

@end

@implementation ReceiptHelper

- (void)getStoreReceiptWithPromise:(UInt32)promise {
  promise_ = promise;
  [self refreshReceipt];
}

- (NSData*)getStoreReceipt {
  NSBundle *bundle = [NSBundle mainBundle];
  NSURL* receiptURL = [bundle performSelector:@selector(appStoreReceiptURL)];
  return [NSData dataWithContentsOfURL:receiptURL];
}

- (void)refreshReceipt {
    request_ = [[SKReceiptRefreshRequest alloc] init];
    request_.delegate = self;
    [request_ start];
}

- (void)requestDidFinish:(SKRequest*)request {
  if (validatingReceipt_) {
    [self doValidation:[self getStoreReceipt]];
  } else {
    [self.delegate didReceiveReceipt:[self getStoreReceipt]
                          forPromise:promise_];
  }
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error {
  if (validatingReceipt_) {
    [self.delegate didValidateReceiptWithResult:NO forPromise:promise_];
    validatingReceipt_ = NO;
  } else {
    [self.delegate receiptDidFailWithError:error forPromise:promise_];
  }
}

- (void)validateReceiptWithPromise:(UInt32)promise {
  promise_ = promise;
  validatingReceipt_ = YES;
  [self refreshReceipt];
}

- (void)doValidation:(NSData*)receipt {
  NSError *error = nil;
  NSString* base64 = [receipt base64EncodedStringWithOptions:0];
  NSDictionary* requestContents = @{ @"receipt-data": base64 };
  NSData* requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                        options:0
                                                          error:&error];
  NSURL* url = nil;
  if (self.debugEnable)
    url = [NSURL URLWithString:VALIDATION_SANDBOX_URL];
  else
    url = [NSURL URLWithString:VALIDATION_PRODUCTION_URL];

  if (requestData) {
    NSMutableURLRequest* request =
        [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                  validatingReceipt_ = NO;

                  if (!error) {
                    NSError* jsonError = nil;
                    NSDictionary* jsonResponse =
                        [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&jsonError];
                    NSInteger status =
                        [[jsonResponse valueForKey:@"status"] integerValue];
                    if (status == 0) {
                      [self.delegate didValidateReceiptWithResult:YES
                                                       forPromise:promise_];
                      return;
                    }
                  }
                  [self.delegate didValidateReceiptWithResult:NO
                                                   forPromise:promise_];
                }] resume];
  } else {
    validatingReceipt_ = NO;
    [self.delegate didValidateReceiptWithResult:NO forPromise:promise_];
  }
}

@end
