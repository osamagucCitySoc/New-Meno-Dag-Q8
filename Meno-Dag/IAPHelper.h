//
//  IAPHelper.h
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const IAPHelperProductRestoreNotification;
UIKIT_EXTERN NSString *const IAPHelperProductFailedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
@property(strong, nonatomic) NSURLConnection* validateConnection;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
