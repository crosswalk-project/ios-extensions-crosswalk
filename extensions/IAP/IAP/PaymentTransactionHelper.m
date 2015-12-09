// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PaymentTransactionHelper.h"

@implementation PaymentTransactionHelper

- (id)init {
  if (self = [super init]) {
    [[SKPaymentQueue defaultQueue]  addTransactionObserver:self];
  }
  return self;
}

- (void)dealloc {
  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)purchase:(NSDictionary*)order withPromise:(UInt32)promise {
  NSDictionary* products = [self.delegate getProductsDict];
  NSString* identifier = [order valueForKey:@"productId"];
  NSNumber* quantity = [order valueForKey:@"count"];
  promise_ = promise;

  SKMutablePayment *payment =
      [SKMutablePayment paymentWithProduct:[products objectForKey:identifier]];
  payment.quantity = [quantity unsignedIntegerValue];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactionsWithPromise:(UInt32)promise {
  promise_ = promise;
  restoredProducts_ = [[NSMutableArray alloc] init];
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue*)queue
 updatedTransactions:(NSArray*)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    BOOL canFinishTransaction = NO;

    switch (transaction.transactionState) {
      case SKPaymentTransactionStatePurchasing:
        break;
      case SKPaymentTransactionStatePurchased: {
        NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            transaction.payment.productIdentifier, @"productId", nil];
        [self.delegate didFinishTransaction:dictionary forPromise:promise_];
        canFinishTransaction = YES;
        break;
      }
      case SKPaymentTransactionStateFailed: {
        [self.delegate transactionDidFailWithError:transaction.error
                                        forPromise:promise_];
        canFinishTransaction = YES;
        break;
      }
      case SKPaymentTransactionStateRestored: {
        [restoredProducts_ addObject:
            transaction.originalTransaction.payment.productIdentifier];
        canFinishTransaction = YES;
        break;
      }
      default:
        break;
    }

    if (canFinishTransaction)
      [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  }
}

- (void)paymentQueue:(SKPaymentQueue*)queue
		restoreCompletedTransactionsFailedWithError:(NSError*)error {
  [self.delegate restoreDidFailWithError:error forPromise:promise_ ];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:
    (SKPaymentQueue*)queue {
  [self.delegate didRestoreProducts:restoredProducts_ forPromise:promise_];
}

- (void)paymentQueue:(SKPaymentQueue*)queue
    updatedDownloads:(NSArray*)downloads {
  // The downloads should be handled by the developer himself, so we will not
  // manage it here.
}

@end
