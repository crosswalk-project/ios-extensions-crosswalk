// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PaymentTransactionHelper.h"

@interface PaymentTransactionHelper()

// The array of restored products which were purchased before.
@property(nonatomic, strong) NSMutableArray* restoredProducts;

// Delegate methods of SKPaymentTransactionObserver.
- (void)paymentQueue:(SKPaymentQueue*)queue
 updatedTransactions:(NSArray*)transactions;
- (void)paymentQueue:(SKPaymentQueue*)queue
    restoreCompletedTransactionsFailedWithError:(NSError*)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue;

@end

@implementation PaymentTransactionHelper {
    // The promise ID which is used for the current request.
    NSUInteger _promise;
}

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue]  addTransactionObserver:self];
        self.delegate = (id<PaymentTransactionHelperDelegate>)extension;
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)purchase:(NSDictionary*)order withPromise:(NSUInteger)promise {
    NSDictionary* products = [self.delegate getProducts];
    NSString* identifier = [order valueForKey:@"productId"];
    NSNumber* quantity = [order valueForKey:@"count"];
    _promise = promise;

    SKMutablePayment *payment =
        [SKMutablePayment paymentWithProduct:[products objectForKey:identifier]];
    payment.quantity = [quantity unsignedIntegerValue];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactionsWithPromise:(NSUInteger)promise {
    _promise = promise;
    self.restoredProducts = [[NSMutableArray alloc] init];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue*)queue
 updatedTransactions:(NSArray*)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        BOOL canFinishTransaction = YES;

        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                canFinishTransaction = NO;
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                NSDictionary* dictionary =
                    [NSDictionary dictionaryWithObjectsAndKeys:
                    transaction.payment.productIdentifier, @"productId", nil];
                [self.delegate didTransactionFinished:dictionary
                                          withPromise:_promise];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [self.delegate didTransactionFailedWithError:transaction.error
                                                 withPromise:_promise];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [self.restoredProducts addObject:
                    transaction.originalTransaction.payment.productIdentifier];
                break;
            }
            default: {
                canFinishTransaction = NO;
                break;
            }
        }

        if (canFinishTransaction)
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)paymentQueue:(SKPaymentQueue*)queue
		restoreCompletedTransactionsFailedWithError:(NSError*)error {
    [self.delegate didFailedRestoreWithError:error withPromise:_promise ];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:
    (SKPaymentQueue*)queue {
    [self.delegate didProductsRestored:self.restoredProducts
                           withPromise:_promise];
}

@end
