//
//  ServicesViewController.m
//
//  Created by Housein Jouhar on 8/19/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "ServicesViewController.h"
#import <AdSupport/AdSupport.h>
#import "followersExchangePurchase.h"
#import "UICKeyChainStore.h"

@interface ServicesViewController ()<UIAlertViewDelegate>

@end

@implementation ServicesViewController
{
    NSArray* products;
    NSString* numberToBlock;
    int buyInt;
    NSString* phonePartSearch1;
    NSString* nameSearch1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pp:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pr:) name:IAPHelperProductRestoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pc:) name:IAPHelperProductFailedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 800);
    
    phonePartSearch1 = @"phonePartSearch";
    nameSearch1 = @"nameSearch";
    
    [self addActivityView];
    
    [self reload];
}

-(void)addActivityView
{
    for (UIView *view in [self.navigationController view].subviews)
    {
        if (view.tag == 383)
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    UIView *mainActionView;
    
    if (([UIApplication sharedApplication].statusBarOrientation == 3 || [UIApplication sharedApplication].statusBarOrientation == 4) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mainActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
    }
    else
    {
        mainActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    }
    
    mainActionView.tag = 383;
    
    [mainActionView setBackgroundColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.8]];
    
    [[self.navigationController view]addSubview:mainActionView];
    
    UIImageView *actImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading-icon.png"]];
    
    [actImg setFrame:CGRectMake(0, 0, 120, 120)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat: 999];
    animation.duration = 170.5f;
    [actImg.layer addAnimation:animation forKey:@"MyAnimation"];
    
    actImg.center = mainActionView.center;
    
    [mainActionView addSubview:actImg];
}

-(void)removeActivityView
{
    for (UIView *view in [self.navigationController view].subviews)
    {
        if (view.tag == 383)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [view removeFromSuperview];
            });
            break;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)closeMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI Method
- (void)reload {
    products = nil;
    [[followersExchangePurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *productss) {
        if (success) {
            products = productss;
            for(SKProduct* product in products)
            {
                NSLog(@"%@",[product productIdentifier]);
                NSString* ss = (NSString*)[NSString stringWithFormat:@"%@",[product productIdentifier]];
                
                if([ss rangeOfString:@"44"].location != NSNotFound)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _blockPriceText.text = [NSString stringWithFormat:@"%.02f",product.price.floatValue];
                        [self removeActivityView];
                    });
                }else if([ss rangeOfString:@"11"].location != NSNotFound)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _partPriceText.text = [NSString stringWithFormat:@"%.02f",product.price.floatValue];
                    });
                }else if([ss rangeOfString:@"22"].location != NSNotFound)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _namePriceText.text = [NSString stringWithFormat:@"%.02f",product.price.floatValue];
                    });
                }else if([ss rangeOfString:@"55"].location != NSNotFound)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _adRemovePriceText.text = [NSString stringWithFormat:@"%.02f",product.price.floatValue];
                    });
                }
            }
        }
    }];
}

#pragma mark purchase method
- (IBAction)restoreClicked:(id)sender {
    followersExchangePurchase *inAppPurchaseHelper = [followersExchangePurchase sharedInstance];
    [inAppPurchaseHelper restoreCompletedTransactions];
    
    if ([inAppPurchaseHelper productPurchased:@"arabdevs.menoDagGold.11"]){
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"phonePartSearch"];
        }
        [store synchronize];

    }
    
    if ([inAppPurchaseHelper productPurchased:@"arabdevs.menoDagGold.22"]){
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"nameSearch"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"nameSearch"];
        }
        [store synchronize];
    }
    
    if ([inAppPurchaseHelper productPurchased:@"arabdevs.menoDag.55"]){
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        
        @try
        {
            [store setString:@"YES" forKey:@"ads"];
        } @catch (NSException *exception) {
            [store setString:@"YES" forKey:@"ads"];
        }
        [store synchronize];
    }
    
    [self removeActivityView];
}

- (IBAction)blockClicked:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"بلوك لرقمك" message:@"من فضلك أدخل الرقم" delegate:self cancelButtonTitle:@"إلغاء" otherButtonTitles:@"بلوك", nil];
    alert.tag = 777;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    [alert show];
}
- (IBAction)nameClicked:(id)sender {
    if (products.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"فشل في الإتصال" message:@"رجاء تأكد من إتصال الإنترنت لديك وحاول مرة أخرى." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self addActivityView];
    });
    buyInt = 1;
    SKProduct *product = products[buyInt];
    [[followersExchangePurchase sharedInstance] buyProduct:product];

}

- (IBAction)removeAdsClicked:(id)sender {
    if (products.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"فشل في الإتصال" message:@"رجاء تأكد من إتصال الإنترنت لديك وحاول مرة أخرى." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self addActivityView];
    });
    buyInt = 3;
    SKProduct *product = products[buyInt];
    [[followersExchangePurchase sharedInstance] buyProduct:product];
}

- (IBAction)partClicked:(id)sender {
    if (products.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"فشل في الإتصال" message:@"رجاء تأكد من إتصال الإنترنت لديك وحاول مرة أخرى." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self addActivityView];
    });
    buyInt = 0;
    SKProduct *product = products[buyInt];
    [[followersExchangePurchase sharedInstance] buyProduct:product];
}


-(void)buyBlockNumber
{
    if (products.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"فشل في الإتصال" message:@"رجاء تأكد من إتصال الإنترنت لديك وحاول مرة أخرى." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self addActivityView];
    });
    buyInt = 2;
    SKProduct *product = products[buyInt];
    [[followersExchangePurchase sharedInstance] buyProduct:product];
}


- (void)pp:(NSNotification *)notification {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfNumbers"] != 7493)return;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString * productIdentifier = (NSString*)notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم الشراء" message:@"تم الشراء شكرا لك." delegate:nil cancelButtonTitle:@"موافق" otherButtonTitles:nil];
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            if ([product.productIdentifier isEqualToString:productIdentifier]) {
                NSLog(@"%@",product.productIdentifier);
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
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self removeActivityView];
                        [alert show];
                    });
                }if([ss rangeOfString:@"22"].location != NSNotFound)
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    
                    @try
                    {
                        [store setString:@"YES" forKey:@"nameSearch"];
                    } @catch (NSException *exception) {
                        [store setString:@"YES" forKey:@"nameSearch"];
                    }
                    [store synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self removeActivityView];
                        [alert show];
                    });
                }if([ss rangeOfString:@"44"].location != NSNotFound)
                {
                    
                    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                    NSMutableString *randomString = [NSMutableString stringWithCapacity: 50];
                    
                    for (int i=0; i<50; i++) {
                        [randomString appendFormat: @"%hu", [letters characterAtIndex: arc4random_uniform([letters length])]];
                    }
                    
                    
                    numberToBlock= [numberToBlock stringByAppendingFormat:@"#%@",randomString];
                    
                    NSData *data = [numberToBlock dataUsingEncoding:NSUTF8StringEncoding];
                    
                    // base 64
                    numberToBlock = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    
                    //salt
                    numberToBlock = [numberToBlock stringByAppendingString:[numberToBlock substringFromIndex:[numberToBlock length] - 1]];
                    
                    //opp
                    NSMutableString *reversedString = [NSMutableString string];
                    NSInteger charIndex = [numberToBlock length];
                    while (charIndex > 0) {
                        charIndex--;
                        NSRange subStrRange = NSMakeRange(charIndex, 1);
                        [reversedString appendString:[numberToBlock substringWithRange:subStrRange]];
                    }
                    
                    NSString*encryptedSources = [[NSString alloc]initWithString:reversedString];
                    
                    //4 8
                    NSString* ch1 = [encryptedSources substringWithRange:NSMakeRange(4, 1)];
                    NSString* ch2 = [encryptedSources substringWithRange:NSMakeRange(8, 1)];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:ch2];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(8, 1) withString:ch1];
                    
                    // 10 19
                    ch1 = [encryptedSources substringWithRange:NSMakeRange(10, 1)];
                    ch2 = [encryptedSources substringWithRange:NSMakeRange(19, 1)];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:ch2];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(19, 1) withString:ch1];
                    
                    // 20 1
                    ch1 = [encryptedSources substringWithRange:NSMakeRange(1, 1)];
                    ch2 = [encryptedSources substringWithRange:NSMakeRange(20, 1)];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:ch2];
                    encryptedSources = [encryptedSources stringByReplacingCharactersInRange:NSMakeRange(20, 1) withString:ch1];
                    


                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/menoDag/encMOH/blockIt.php"]];
                        
                        // Specify that it will be a POST request
                        request.HTTPMethod = @"POST";
                        
                        // This is how we set header fields
                        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        
                        // Convert your data and set your request's HTTPBody property
                        NSString *stringData = [NSString stringWithFormat:@"phone=%@", numberToBlock];
                        NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
                        request.HTTPBody = requestBodyData;
                        
                        NSData *response = [NSURLConnection sendSynchronousRequest:request
                                                                 returningResponse:nil error:nil];
                        
                        NSLog(@"%@",[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self removeActivityView];
                            [alert show];
                        });

                    });
                }if([ss rangeOfString:@"55"].location != NSNotFound)
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    
                    @try
                    {
                        [store setString:@"YES" forKey:@"ads"];
                    } @catch (NSException *exception) {
                        [store setString:@"YES" forKey:@"ads"];
                    }
                    [store synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self removeActivityView];
                        [alert show];
                    });
                }
                *stop = YES;
            }
        }
    }];
    
}

- (void)pc:(NSNotification *)notification {
    numberToBlock = @"";
    buyInt = -1;
    [self removeActivityView];
}


- (void)pr:(NSNotification *)notification {
    NSString * productIdentifier = notification.object;
    [products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        
        NSString* ss = (NSString*)[NSString stringWithFormat:@"%@",productIdentifier];
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
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

                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم" message:@"تم إسترجاع البحث برقم غير كامل" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
                [alert show];
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

                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم" message:@"تم إسترجاع البحث بالإسم" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
                [alert show];
            }else if([ss rangeOfString:@"55"].location != NSNotFound)
            {
                UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                
                @try
                {
                    [store setString:@"YES" forKey:@"ads"];
                } @catch (NSException *exception) {
                    [store setString:@"YES" forKey:@"ads"];
                }
                [store synchronize];
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تم" message:@"تم إسترجاع إزالة الإعلانات" delegate:nil cancelButtonTitle:@"تم" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 777)
    {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            numberToBlock = [textField text];
            [self buyBlockNumber];
        }
    }
}

@end
