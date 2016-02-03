// Copyright (c) 2016 Intel Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FingerprintExtension.h"

@import LocalAuthentication;

@interface FingerprintExtension()

- (void)jsfunc_authenticate:(NSUInteger)cid
                     reason:(NSString*)reason
                   _Promise:(NSUInteger)promise;

@end

@implementation FingerprintExtension

- (void)jsfunc_authenticate:(NSUInteger)cid
                     reason:(NSString*)reason
                   _Promise:(NSUInteger)promise {
    LAContext* context = [[LAContext alloc] init];
    NSError* error = nil;
    BOOL canAuthenticate = NO;

    canAuthenticate = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                           error:&error];
    if (!canAuthenticate) {
        NSDictionary* arg = [NSDictionary dictionaryWithObjectsAndKeys:
            @"NotSupportError", @"name", nil];
        [self invokeCallback:promise key:@"reject" arguments:[NSArray arrayWithObjects:arg, nil]];
        return;
    }

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:reason
                      reply:^(BOOL success, NSError* authenticationError) {
        if (success) {
           [self invokeCallback:promise key:@"resolve" arguments:nil];
        } else {
           NSDictionary* arg = [NSDictionary dictionaryWithObjectsAndKeys:
               @"OperationError", @"name", authenticationError.localizedDescription, @"message", nil];
           [self invokeCallback:promise key:@"reject" arguments:[NSArray arrayWithObjects:arg, nil]];
        }
    }];
}

@end
