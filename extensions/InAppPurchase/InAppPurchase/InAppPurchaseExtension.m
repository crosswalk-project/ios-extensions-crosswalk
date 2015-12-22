// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchaseExtension.h"

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "PaymentTransactionHelper.h"
#import "ProductsRequestHelper.h"
#import "ReceiptHelper.h"

@interface InAppPurchaseExtension() <PaymentTransactionHelperDelegate,
                                     ReceiptHelperDelegate,
                                     ProductsRequestHelperDelegate>

// If this prpperty is set to YES, then the sandbox environment will be used.
@property(nonatomic, assign) BOOL debugEnabled;

@property(nonatomic, strong) ProductsRequestHelper* productRequestHelper;
@property(nonatomic, strong) ReceiptHelper* receiptHelper;
@property(nonatomic, strong) PaymentTransactionHelper* paymentTransactionHelper;

// Methods used to hook the js interfaces.
- (void)jsfunc_init:(NSUInteger)cid options:(NSDictionary*)options
            promise:(NSUInteger)promise;
- (void)jsfunc_queryProductsInfo:(NSUInteger)cid productIds:(NSArray*)productIds
    promise:(NSUInteger)promise;
- (void)jsfunc_purchase:(NSUInteger)cid order:(NSDictionary*)order
    promise:(NSUInteger)promise;
- (void)jsfunc_getReceipt:(NSUInteger)cid promise:(NSUInteger)promise;
- (void)jsfunc_validateReceipt:(NSUInteger)cid promise:(NSUInteger)promise;
- (void)jsfunc_restore:(NSUInteger)cid promise:(NSUInteger)promise;

// Delegate methods of PaymentTransactionHelperDelegate.
- (NSDictionary*)getProducts;
- (void)didTransactionFinished:(NSDictionary*)transaction
                   withPromise:(NSUInteger)promise;
- (void)didTransactionFailedWithError:(NSError*)error
                          withPromise:(NSUInteger)promise;
- (void)didProductsRestored:(NSArray*)products withPromise:(NSUInteger)promise;
- (void)didFailedRestoreWithError:(NSError*)error
                      withPromise:(NSUInteger)promise;

// Delegate methods of ProductsRequestHelperDelegate.
- (void)didReceivedProducts:(NSArray*)products withPromise:(NSUInteger)promise;
- (void)didRequestFailedWithError:(NSError*)error
                      withPromise:(NSUInteger)promise;

// Delegate methods of ReceiptHelperDelegate.
- (void)didReceivedReceipt:(NSData*)receipt withPromise:(NSUInteger)promise;
- (void)didFailedReceiptWithError:(NSError*)error withPromise:(NSUInteger)promise;
- (void)didValidatedReceiptWithResult:(BOOL)result withPromise:(NSUInteger)promise;

@end

@implementation InAppPurchaseExtension

- (void)jsfunc_init:(NSUInteger)cid options:(NSDictionary*)options
    promise:(NSUInteger)promise {
    if ([SKPaymentQueue canMakePayments]) {
        self.debugEnabled = [[options valueForKey:@"debug"] boolValue];

        self.productRequestHelper = [[ProductsRequestHelper alloc]
            initWithIAPExtension:self];
        self.receiptHelper = [[ReceiptHelper alloc]
            initWithIAPExtension:self];
        self.receiptHelper.debugEnabled = self.debugEnabled;
        self.paymentTransactionHelper = [[PaymentTransactionHelper alloc]
            initWithIAPExtension:self];
        [self invokeCallback:promise key:@"resolve" arguments:nil];
    } else {
        [self invokeCallback:promise key:@"reject" arguments:nil];
    }
}

- (void)jsfunc_queryProductsInfo:(NSUInteger)cid
                      productIds:(NSArray*)productIds
                         promise:(NSUInteger)promise {
    [self.productRequestHelper sendRequestWithProductIds:productIds
                                             withPromise:promise];
}

- (void)jsfunc_purchase:(NSUInteger)cid
                  order:(NSDictionary*)order
                promise:(NSUInteger)promise {
    [self.paymentTransactionHelper purchase:order withPromise:promise];
}

- (void)jsfunc_getReceipt:(NSUInteger)cid promise:(NSUInteger)promise {
    [self.receiptHelper getStoreReceiptWithPromise:promise];
}

- (void)jsfunc_validateReceipt:(NSUInteger)cid promise:(NSUInteger)promise {
    [self.receiptHelper validateReceiptWithPromise:promise];
}

- (void)jsfunc_restore:(NSUInteger)cid promise:(NSUInteger)promise {
    [self.paymentTransactionHelper restoreCompletedTransactionsWithPromise:promise];
}

- (void)didReceivedProducts:(NSArray*)products withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"resolve"
               arguments:[NSArray arrayWithObjects:products, nil]];

}

- (void)didRequestFailedWithError:(NSError*)error
                      withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"reject"
               arguments:[NSArray arrayWithObjects:
                             error.localizedDescription, nil]];
}

- (void)receiptDidFailWithError:(NSError*)error withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"reject"
               arguments:[NSArray arrayWithObjects:
                             error.localizedDescription, nil]];
}

- (void)didReceivedReceipt:(NSData*)receipt withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"resolve"
               arguments:[NSArray arrayWithObjects:
                             [receipt base64EncodedStringWithOptions:0], nil]];
}

- (void)didFailedReceiptWithError:(NSError*)error withPromise:(NSUInteger)promise {
    [self invokeCallback:promise key:@"reject"
        arguments:[NSArray arrayWithObjects:error.localizedDescription, nil]];
}

- (NSDictionary*)getProducts {
    return self.productRequestHelper.products;
}

- (void)didValidatedReceiptWithResult:(BOOL)result withPromise:(NSUInteger)promise {
    if (result)
        [self invokeCallback:promise key:@"resolve" arguments:nil];
    else
        [self invokeCallback:promise key:@"reject" arguments:nil];
}

- (void)didTransactionFinished:(NSDictionary*)transaction
                   withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"resolve"
               arguments:[NSArray arrayWithObjects:transaction, nil]];
}

- (void)didTransactionFailedWithError:(NSError*)error
                          withPromise:(NSUInteger)promise {
    [self invokeCallback:promise key:@"reject"
        arguments:[NSArray arrayWithObjects:error.localizedDescription, nil]];
}

- (void)didProductsRestored:(NSArray*)products withPromise:(NSUInteger)promise {
    [self invokeCallback:promise
                     key:@"resolve"
               arguments:[NSArray arrayWithObjects:products, nil]];}

- (void)didFailedRestoreWithError:(NSError*)error
                      withPromise:(NSUInteger)promise{
    [self invokeCallback:promise key:@"reject"
        arguments:[NSArray arrayWithObjects:error.localizedDescription, nil]];
}

@end
