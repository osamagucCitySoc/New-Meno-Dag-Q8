//
//  followersExchangePurchase.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "followersExchangePurchase.h"

@implementation followersExchangePurchase

+ (followersExchangePurchase *)sharedInstance {
    static dispatch_once_t once;
    static followersExchangePurchase * sharedInstance;
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"arabdevs.menoDag.11",
                                      @"arabdevs.menoDag.22",
                                      @"arabdevs.menoDag.44",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}




@end
