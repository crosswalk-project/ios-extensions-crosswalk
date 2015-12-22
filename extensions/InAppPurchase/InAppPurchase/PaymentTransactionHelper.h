// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class  InAppPurchaseExtension;

@protocol PaymentTransactionHelperDelegate

@required
- (NSDictionary*)getProducts;
- (void)didTransactionFinished:(NSDictionary*)transaction
                   withPromise:(NSUInteger)promise;
- (void)didTransactionFailedWithError:(NSError*)error
                          withPromise:(NSUInteger)promise;
- (void)didProductsRestored:(NSArray*)products withPromise:(NSUInteger)promise;
- (void)didFailedRestoreWithError:(NSError*)error
                      withPromise:(NSUInteger)promise;

@end

@interface PaymentTransactionHelper : NSObject<SKPaymentTransactionObserver>

@property(nonatomic, weak) id<PaymentTransactionHelperDelegate> delegate;

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension;
- (void)purchase:(NSDictionary*)order withPromise:(NSUInteger)promise;
- (void)restoreCompletedTransactionsWithPromise:(NSUInteger)promise;

@end
