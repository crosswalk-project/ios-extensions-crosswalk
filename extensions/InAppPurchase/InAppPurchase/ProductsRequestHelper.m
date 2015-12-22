// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ProductsRequestHelper.h"

@interface ProductsRequestHelper()

- (NSString*)localizedPrice:(SKProduct*)product;

// Delegate methods of SKProductsRequestDelegate.
- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response;
- (void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end

@implementation ProductsRequestHelper {
    // The promise ID which is used for the current request.
    NSUInteger _promise;

    NSMutableDictionary* _products;
}

@synthesize products = _products;

- (id)initWithIAPExtension:(InAppPurchaseExtension*)extension {
    if (self = [super init]) {
        self.products = [[NSMutableDictionary alloc] init];
        self.delegate = (id<ProductsRequestHelperDelegate>)extension;
    }
    return self;
}

- (void)sendRequestWithProductIds:(NSArray*)productIds
                      withPromise:(NSUInteger)promise {
    SKProductsRequest* request = [[SKProductsRequest alloc]
        initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    _promise = promise;
    [request start];
}

- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response {
    NSMutableArray* products = [NSMutableArray array];
    for (SKProduct* product in response.products) {
        [_products setObject:product forKey:product.productIdentifier];
        NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            product.productIdentifier, @"productId",
            product.localizedTitle, @"title",
            product.localizedDescription, @"description",
            [self localizedPrice:product], @"price",
            nil];
        [products addObject:dictionary];
    }
    [self.delegate didReceivedProducts:products withPromise:_promise];
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error {
    [self.delegate didRequestFailedWithError:error withPromise:_promise];
}

- (NSString*)localizedPrice:(SKProduct*)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:product.price];
}

@end
