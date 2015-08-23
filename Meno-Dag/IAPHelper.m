//
//  IAPHelper.m
//  twitterExampleIII
//
//  Created by ousamaMacBook on 6/19/13.
//  Copyright (c) 2013 MacBook. All rights reserved.
//

#import "IAPHelper.h"
#import "UICKeyChainStore.h"

@interface IAPHelper () <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@end

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductRestoreNotification = @"IAPHelperProductRestoredNotification";
NSString *const IAPHelperProductFailedNotification = @"IAPHelperProductFailedNotification";

@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    BOOL isRealBuy;
    BOOL alreadyFound;
}

@synthesize validateConnection;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        //delegate for purchasing
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
                NSString* ss = (NSString*)[NSString stringWithFormat:@"%@",productIdentifier];
                if([ss rangeOfString:@"11"].location != NSNotFound)
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    
                    @try
                    {
                        [store setString:@"YES" forKey:@"phonePartSearch"];
                    } @catch (NSException *exception) {
                        [store setString:@"YES" forKey:@"phonePartSearch"];
                    }
                    [store synchronize];

                }else if([ss rangeOfString:@"22"].location != NSNotFound)
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    
                    @try
                    {
                        [store setString:@"YES" forKey:@"nameSearch"];
                    } @catch (NSException *exception) {
                        [store setString:@"YES" forKey:@"nameSearch"];
                    }
                    [store synchronize];
                }else if([ss rangeOfString:@"55"].location != NSNotFound)
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    
                    @try
                    {
                        [store setString:@"YES" forKey:@"ads"];
                    } @catch (NSException *exception) {
                        [store setString:@"YES" forKey:@"ads"];
                    }
                    [store synchronize];                }

                [[NSUserDefaults standardUserDefaults]synchronize];
            } else {
                //NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark - purchasing methods

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
        NSLog(@"Buying %@...", product.productIdentifier);
        SKPayment * payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - purchasing delegates
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                    [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                    [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                    [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    if([self webViewDidLoadAd:transaction])
    {
        NSLog(@"completeTransaction...");
        [self provideContentForProductIdentifier:transaction.payment.productIdentifier occured:transaction.transactionDate];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }else
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"لم يتم الشراء" message:@"إما إنك تخترقنا فأنصحك أن تنسى، أو هناك خطأ راسلنا" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
        [alert show];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...%@",transaction.originalTransaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifierRestored:transaction.originalTransaction.payment.productIdentifier occured:transaction.originalTransaction.transactionDate];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:transaction.originalTransaction.payment.productIdentifier userInfo:nil];
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }else
    {
        [self provideContentForProductIdentifierCanceled:transaction.originalTransaction.payment.productIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier occured:(NSDate*)occured {
    NSString* ss = (NSString*)[NSString stringWithFormat:@"%@",productIdentifier];
    
   if([ss rangeOfString:@"11"].location != NSNotFound)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        }
        [store synchronize];

    }else if([ss rangeOfString:@"22"].location != NSNotFound)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"nameSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"nameSearch"];
        }
        [store synchronize];

    }else if([ss rangeOfString:@"55"].location != NSNotFound)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
        NSString* expirationDate = [formatter stringFromDate:[occured dateByAddingTimeInterval:(90*24*3600)]];
        @try
        {
            
            [store setString:@"YES" forKey:@"ads"];
            [store setString:expirationDate forKey:@"adsEnd"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"ads"];
            [store setString:expirationDate forKey:@"adsEnd"];
        }
        [store synchronize];
    }

        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)provideContentForProductIdentifierRestored:(NSString *)productIdentifier occured:(NSDate*)occured{
    NSString* ss = (NSString*)[NSString stringWithFormat:@"%@",productIdentifier];
    if([ss rangeOfString:@"11"].location != NSNotFound)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        }
        [store synchronize];

        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreNotification object:productIdentifier userInfo:nil];
    }else if([ss rangeOfString:@"22"].location != NSNotFound)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"nameSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"nameSearch"];
        }
        [store synchronize];

        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreNotification object:productIdentifier userInfo:nil];
    }else if([ss rangeOfString:@"55"].location != NSNotFound)
    {
        
        long dayDiff = [self daysBetweenDate:occured andDate:[NSDate date]];
        
        if(alreadyFound || dayDiff <= 90)
        {
            alreadyFound = YES;
            UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
            NSString* expirationDate = [formatter stringFromDate:[occured dateByAddingTimeInterval:(90*24*3600)]];
            @try
            {
                
                [store setString:@"YES" forKey:@"ads"];
                [store setString:expirationDate forKey:@"adsEnd"];
            } @catch (NSException *exception) {
                [store setString:@"YES" forKey:@"ads"];
                [store setString:expirationDate forKey:@"adsEnd"];
            }
            [store synchronize];
            [_purchasedProductIdentifiers addObject:productIdentifier];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreNotification object:productIdentifier userInfo:nil];
        }else
        {
            alreadyFound = NO;
            UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
            @try
            {
                [store setString:@"NO" forKey:@"ads"];
            } @catch (NSException *exception) {
                [store setString:@"NO" forKey:@"ads"];
            }
            [store synchronize];
        }
    }
}


-(long)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (void)provideContentForProductIdentifierCanceled:(NSString *)productIdentifier {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    alreadyFound = NO;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(BOOL)webViewDidLoadAd:(SKPaymentTransaction *)transaction
{
    NSString* string = [[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    
    NSString *post = [NSString stringWithFormat:@"purchase=%@",string];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/validateMe2.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    NSLog(@"%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
    BOOL resL = [[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]isEqual:@"OK"];
    
    if (resL)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:7493 forKey:@"numberOfNumbers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return resL;
}

- (BOOL)verifyReceipt:(SKPaymentTransaction *)transaction {
    return NO;
    /*NSString *jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
     NSLog(@"%@",jsonObjectString);
     NSString *completeString = [NSString stringWithFormat:@"http://osamalogician.com/validateMe2.php?receipt=%@", jsonObjectString];
     NSURL *urlForValidation = [NSURL URLWithString:completeString];
     NSMutableURLRequest *validationRequest = [[NSMutableURLRequest alloc] initWithURL:urlForValidation];
     [validationRequest setHTTPMethod:@"GET"];
     NSData *responseData = [NSURLConnection sendSynchronousRequest:validationRequest returningResponse:nil error:nil];
     NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
     NSInteger response = [responseString integerValue];
     return (response == 0);*/
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
