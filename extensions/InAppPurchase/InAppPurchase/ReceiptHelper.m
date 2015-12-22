// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ReceiptHelper.h"

#import <StoreKit/StoreKit.h>

NSString* const kSandboxUrl = @"https://sandbox.itunes.apple.com/verifyReceipt";
NSString* const kProductUrl = @"https://buy.itunes.apple.com/verifyReceipt";

@interface ReceiptHelper()

- (NSData*)getStoreReceipt;
- (void)refreshReceipt;
- (void)validateReceipt:(NSData*)receipt;

// Delegate methods of SKRequestDelegate.
- (void)requestDidFinish:(SKRequest*)request;
- (void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end

@implementation ReceiptHelper {
    // The promise ID which is used for the current request.
    NSUInteger _promise;

    BOOL _validatingReceipt;
    SKReceiptRefreshRequest* _request;
}

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension {
    if (self = [super init]) {
        self.delegate = (id<ReceiptHelperDelegate>)extension;
    }
    return self;
}

- (void)getStoreReceiptWithPromise:(NSUInteger)promise {
    _promise = promise;
    [self refreshReceipt];
}

- (NSData*)getStoreReceipt {
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL* receiptURL = [bundle performSelector:@selector(appStoreReceiptURL)];
    return [NSData dataWithContentsOfURL:receiptURL];
}

- (void)refreshReceipt {
    _request = [[SKReceiptRefreshRequest alloc] init];
    _request.delegate = self;
    [_request start];
}

- (void)requestDidFinish:(SKRequest*)request {
    if (_validatingReceipt) {
        [self validateReceipt:[self getStoreReceipt]];
    } else {
        [self.delegate didReceivedReceipt:[self getStoreReceipt]
                              withPromise:_promise];
    }
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error {
    if (_validatingReceipt) {
        [self.delegate didValidatedReceiptWithResult:NO withPromise:_promise];
        _validatingReceipt = NO;
    } else {
        [self.delegate didFailedReceiptWithError:error withPromise:_promise];
    }
}

- (void)validateReceiptWithPromise:(NSUInteger)promise {
    _promise = promise;
    _validatingReceipt = YES;
    [self refreshReceipt];
}

- (void)validateReceipt:(NSData*)receipt {
    NSError *error = nil;
    NSString* base64 = [receipt base64EncodedStringWithOptions:0];
    NSDictionary* requestContents = @{ @"receipt-data": base64 };
    NSData* requestData =
        [NSJSONSerialization dataWithJSONObject:requestContents
                                        options:0
                                          error:&error];
    NSURL* url = nil;
    if (self.debugEnabled)
        url = [NSURL URLWithString:kSandboxUrl];
    else
        url = [NSURL URLWithString:kProductUrl];

    if (requestData) {
        NSMutableURLRequest* request =
            [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:requestData];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                _validatingReceipt = NO;

                if (!error) {
                    NSError* jsonError = nil;
                    NSDictionary* jsonResponse =
                        [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&jsonError];
                    NSInteger status =
                        [[jsonResponse valueForKey:@"status"] integerValue];
                    if (status == 0) {
                        [self.delegate didValidatedReceiptWithResult:YES
                                                         withPromise:_promise];
                        return;
                    }
                }
                [self.delegate didValidatedReceiptWithResult:NO
                                                 withPromise:_promise];
            }] resume];
    } else {
        _validatingReceipt = NO;
        [self.delegate didValidatedReceiptWithResult:NO withPromise:_promise];
    }
}

@end
