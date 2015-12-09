// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol ProductsRequestHelperDelegate
@required

- (void)didReceiveProducts:(NSArray*)products forPromise:(UInt32)promise;
- (void)requestDidFailWithError:(NSError*)error forPromise:(UInt32)promise;

@end

@interface ProductsRequestHelper : NSObject<SKProductsRequestDelegate> {
 @private
  // The promise ID which is used for the current request.
  UInt32 promise_;
}

@property(nonatomic, assign) id<ProductsRequestHelperDelegate> delegate;
@property(nonatomic, strong) NSMutableDictionary* productsDict;

- (id)init;
- (void)sendRequestWithProductIds:(NSArray*)productIds
                       andPromise:(UInt32)promise;

// Delegate methods of SKProductsRequestDelegate.
- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response;
- (void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end
