// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol ReceiptHelperDelegate
@required

- (void)didReceiveReceipt:(NSData*)receipt forPromise:(UInt32)promise;
- (void)receiptDidFailWithError:(NSError*)error forPromise:(UInt32)promise;
- (void)didValidateReceiptWithResult:(BOOL)result forPromise:(UInt32)promise;

@end

@interface ReceiptHelper : NSObject<SKRequestDelegate> {
 @private
  // The promise ID which is used for the current request.
  UInt32 promise_;

  BOOL validatingReceipt_;
  SKReceiptRefreshRequest* request_;
}

@property(nonatomic, assign) id<ReceiptHelperDelegate> delegate;
@property(nonatomic, assign) BOOL debugEnable;

- (void)getStoreReceiptWithPromise:(UInt32)promise;
- (void)validateReceiptWithPromise:(UInt32)promise;

// Delegate methods of SKRequestDelegate.
- (void)requestDidFinish:(SKRequest*)request;
- (void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end
