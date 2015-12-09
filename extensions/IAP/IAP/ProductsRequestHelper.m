// Copyright (c) 2015 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ProductsRequestHelper.h"

@interface ProductsRequestHelper(Private)

- (NSString*)localizedPrice:(SKProduct*)product;

@end

@implementation ProductsRequestHelper

- (id)init {
  if (self = [super init]) {
    self.productsDict = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)sendRequestWithProductIds:(NSArray*)productIds
                      andPromise:(UInt32)promise {
  SKProductsRequest* request = [[SKProductsRequest alloc]
      initWithProductIdentifiers:[NSSet setWithArray:productIds]];
  request.delegate = self;
  promise_ = promise;
  [request start];
}

- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response {
  NSMutableArray* products = [NSMutableArray array];
  for (SKProduct* product in response.products) {
    [self.productsDict setObject:product forKey:product.productIdentifier];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        product.productIdentifier, @"productId",
        product.localizedTitle, @"title",
        product.localizedDescription, @"description",
        [self localizedPrice:product], @"price",
        nil];
    [products addObject:dictionary];
  }
  [self.delegate didReceiveProducts:products forPromise:promise_];
}

- (void)request:(SKRequest*)request didFailWithError:(NSError*)error {
  [self.delegate requestDidFailWithError:error forPromise:promise_];
}

- (NSString*)localizedPrice:(SKProduct*)product {
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:product.priceLocale];
  return [numberFormatter stringFromNumber:product.price];
}

@end
