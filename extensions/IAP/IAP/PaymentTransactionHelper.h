// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol PaymentTransactionHelperDelegate
@required

- (NSDictionary*)getProductsDict;
- (void)didFinishTransaction:(NSDictionary*)transaction
                  forPromise:(UInt32)promise;
- (void)transactionDidFailWithError:(NSError*)error
                         forPromise:(UInt32)promise;
- (void)didRestoreProducts:(NSArray*)products forPromise:(UInt32)promise;
- (void)restoreDidFailWithError:(NSError*)error forPromise:(UInt32)promise;

@end

@interface PaymentTransactionHelper : NSObject<SKPaymentTransactionObserver> {
 @private
  // The promise ID which is used for the current request.
  UInt32 promise_;

  // The array of restored products which were purchased before.
  NSMutableArray* restoredProducts_;
}

@property(nonatomic, assign) id<PaymentTransactionHelperDelegate> delegate;

- (id)init;
- (void)purchase:(NSDictionary*)order withPromise:(UInt32)promise;
- (void)restoreCompletedTransactionsWithPromise:(UInt32)promise;

// Delegate methods of SKPaymentTransactionObserver.
- (void)paymentQueue:(SKPaymentQueue*)queue
 updatedTransactions:(NSArray*)transactions;
- (void)paymentQueue:(SKPaymentQueue*)queue
    restoreCompletedTransactionsFailedWithError:(NSError*)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue;
- (void)paymentQueue:(SKPaymentQueue*)queue
    updatedDownloads:(NSArray*)downloads;

@end
