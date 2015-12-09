// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "IAP.h"

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <XWalkView/XWalkExtension.h>

#import "PaymentTransactionHelper.h"
#import "ProductsRequestHelper.h"
#import "ReceiptHelper.h"

@interface IAP : XWalkExtension<PaymentTransactionHelperDelegate,
                                ReceiptHelperDelegate,
                                ProductsRequestHelperDelegate> {
 @private
  // If this flag is set to YES, then the sandbox environment will be used.
  BOOL debugEnable_;

  // Helper classes used to finish the in-app purchase workflow.
  ProductsRequestHelper* productRequestHelper_;
  ReceiptHelper* receiptHelper_;
  PaymentTransactionHelper* paymentTransactionHelper_;
}

// Methods used to hook the js interfaces.
- (void)jsfunc_init:(UInt32)cid options:(NSString*)options
            promise:(UInt32)promise;
- (void)jsfunc_queryProductsInfo:(UInt32)cid productIds:(NSArray*)productIds
    promise:(UInt32)promise;
- (void)jsfunc_purchase:(UInt32)cid order:(NSDictionary*)order
    promise:(UInt32)promise;
- (void)jsfunc_getReceipt:(UInt32)cid promise:(UInt32)promise;
- (void)jsfunc_validateReceipt:(UInt32)cid promise:(UInt32)promise;
- (void)jsfunc_restore:(UInt32)cid promise:(UInt32)promise;

// Delegate methods of PaymentTransactionHelperDelegate.
- (NSDictionary*)getProductsDict;
- (void)didFinishTransaction:(NSDictionary*)transaction
                  forPromise:(UInt32)promise;
- (void)transactionDidFailWithError:(NSError*)error
                         forPromise:(UInt32)promise;
- (void)didRestoreProducts:(NSArray*)products forPromise:(UInt32)promise;
- (void)restoreDidFailWithError:(NSError*)error forPromise:(UInt32)promise;

// Delegate methods of ProductsRequestHelperDelegate.
- (void)didReceiveProducts:(NSArray*)products forPromise:(UInt32)promise;
- (void)requestDidFailWithError:(NSError*)error forPromise:(UInt32)promise;

// Delegate methods of ReceiptHelperDelegate.
- (void)didReceiveReceipt:(NSData*)receipt forPromise:(UInt32)promise;
- (void)receiptDidFailWithError:(NSError*)error forPromise:(UInt32)promise;
- (void)didValidateReceiptWithResult:(BOOL)result forPromise:(UInt32)promise;

- (id)deserialize:(NSString*)str forPromise:(UInt32)promise;
- (void)serialize:(id)object forPromise:(UInt32)promise;

@end

@implementation IAP

- (void)jsfunc_init:(UInt32)cid options:(NSString*)options
    promise:(UInt32)promise {
  if ([SKPaymentQueue canMakePayments]) {
    NSDictionary* optionsDict = [self deserialize:options forPromise:promise];
    if (optionsDict) {
      debugEnable_ = [[optionsDict valueForKey:@"debug"] boolValue];

      productRequestHelper_ = [[ProductsRequestHelper alloc] init];
      productRequestHelper_.delegate = self;
      receiptHelper_ = [[ReceiptHelper alloc] init];
      receiptHelper_.delegate = self;
      receiptHelper_.debugEnable = debugEnable_;
      paymentTransactionHelper_ = [[PaymentTransactionHelper alloc] init];
      paymentTransactionHelper_.delegate = self;
      [self invokeCallback:promise key:@"resolve" arguments:nil];
    }
  } else {
    [self invokeCallback:promise key:@"reject" arguments:nil];
  }
}

- (void)jsfunc_queryProductsInfo:(UInt32)cid
                      productIds:(NSString*)productIds
                         promise:(UInt32)promise {
  NSArray* productArray = [self deserialize:productIds forPromise:promise];
  if (productArray) {
    [productRequestHelper_ sendRequestWithProductIds:productArray
                                          andPromise:promise];
  }
}

- (void)jsfunc_purchase:(UInt32)cid
                  order:(NSString*)order
                promise:(UInt32)promise {
  NSDictionary* orderDict =
      [self deserialize:order forPromise:promise];
  if (orderDict)
    [paymentTransactionHelper_ purchase:orderDict withPromise:promise];
}

- (void)jsfunc_getReceipt:(UInt32)cid promise:(UInt32)promise {
  [receiptHelper_ getStoreReceiptWithPromise:promise];
}

- (void)jsfunc_validateReceipt:(UInt32)cid promise:(UInt32)promise {
  [receiptHelper_ validateReceiptWithPromise:promise];
}

- (void)jsfunc_restore:(UInt32)cid promise:(UInt32)promise {
  [paymentTransactionHelper_ restoreCompletedTransactionsWithPromise:promise];
}

- (void)didReceiveProducts:(NSArray*)products forPromise:(UInt32)promise {
  [self serialize:products forPromise:promise];
}

- (void)requestDidFailWithError:(NSError*)error forPromise:(UInt32)promise {
  [self invokeCallback:promise
                   key:@"reject"
             arguments:[NSArray arrayWithObjects:
                           [error localizedDescription], nil]];
}

- (void)receiptDidFailWithError:(NSError*)error forPromise:(UInt32)promise {
  [self invokeCallback:promise
                   key:@"reject"
             arguments:[NSArray arrayWithObjects:
                           [error localizedDescription], nil]];
}

- (void)didReceiveReceipt:(NSData*)receipt forPromise:(UInt32)promise {
  [self invokeCallback:promise
                   key:@"resolve"
             arguments:[NSArray arrayWithObjects:
                           [receipt base64EncodedStringWithOptions:0], nil]];
}

- (void)didFailReceiptWithError:(NSError*)error forPromise:(UInt32)promise {
  [self invokeCallback:promise key:@"reject"
      arguments:[NSArray arrayWithObjects:[error localizedDescription], nil]];
}

- (NSDictionary*)getProductsDict {
  return productRequestHelper_.productsDict;
}

- (void)didValidateReceiptWithResult:(BOOL)result forPromise:(UInt32)promise {
  if (result)
    [self invokeCallback:promise key:@"resolve" arguments:nil];
  else
    [self invokeCallback:promise key:@"reject" arguments:nil];
}

- (void)didFinishTransaction:(NSDictionary*)transaction
                  forPromise:(UInt32)promise {
  [self serialize:transaction forPromise:promise];
}

- (void)transactionDidFailWithError:(NSError*)error
                         forPromise:(UInt32)promise {
  [self invokeCallback:promise key:@"reject"
      arguments:[NSArray arrayWithObjects:[error localizedDescription], nil]];
}

- (void)didRestoreProducts:(NSArray*)products forPromise:(UInt32)promise {
  [self serialize:products forPromise:promise];
}

- (void)restoreDidFailWithError:(NSError*)error forPromise:(UInt32)promise {
  [self invokeCallback:promise key:@"reject"
      arguments:[NSArray arrayWithObjects:[error localizedDescription], nil]];
}

- (id)deserialize:(NSString*)str forPromise:(UInt32)promise {
  NSError* error = nil;
  id object = [NSJSONSerialization
      JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                 options:NSJSONReadingMutableContainers
                   error:&error];

  if (error) {
    [self invokeCallback:promise key:@"reject"
        arguments:[NSArray arrayWithObjects:[error localizedDescription], nil]];
    return nil;
  } else {
    return object;
  }
}

- (void)serialize:(id)object forPromise:(UInt32)promise {
  NSError* error = nil;
  NSData* data = [NSJSONSerialization dataWithJSONObject:object
                                                 options:kNilOptions
                                                   error:&error];

  if (error) {
    [self invokeCallback:promise key:@"reject"
        arguments:[NSArray arrayWithObjects:[error localizedDescription], nil]];
    return;
  }

  NSString* str =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [self invokeCallback:promise
                   key:@"resolve"
             arguments:[NSArray arrayWithObjects:str, nil]];
}

@end
