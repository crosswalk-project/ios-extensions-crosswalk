// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class  InAppPurchaseExtension;

@protocol ProductsRequestHelperDelegate

@required
- (void)didReceivedProducts:(NSArray*)products withPromise:(NSUInteger)promise;
- (void)didRequestFailedWithError:(NSError*)error
                      withPromise:(NSUInteger)promise;

@end

@interface ProductsRequestHelper : NSObject<SKProductsRequestDelegate>

@property(nonatomic, weak) id<ProductsRequestHelperDelegate> delegate;
@property(nonatomic, strong) NSDictionary* products;

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension;
- (void)sendRequestWithProductIds:(NSArray*)productIds
                      withPromise:(NSUInteger)promise;

@end
