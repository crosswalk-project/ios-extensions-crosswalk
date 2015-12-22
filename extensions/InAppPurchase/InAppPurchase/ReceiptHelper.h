// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class  InAppPurchaseExtension;

@protocol ReceiptHelperDelegate

@required
- (void)didReceivedReceipt:(NSData*)receipt withPromise:(NSUInteger)promise;
- (void)didFailedReceiptWithError:(NSError*)error withPromise:(NSUInteger)promise;
- (void)didValidatedReceiptWithResult:(BOOL)result withPromise:(NSUInteger)promise;

@end

@interface ReceiptHelper : NSObject<SKRequestDelegate>

@property(nonatomic, weak) id<ReceiptHelperDelegate> delegate;
@property(nonatomic, assign) BOOL debugEnabled;

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension;
- (void)getStoreReceiptWithPromise:(NSUInteger)promise;
- (void)validateReceiptWithPromise:(NSUInteger)promise;

@end
