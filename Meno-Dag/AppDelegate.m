//
//  AppDelegate.m
//  Meno-Dag
//
//  Created by Hussein Jouhar on 8/15/15.
//  Copyright (c) 2015 SADAH Software Solutions, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "followersExchangePurchase.h"
#import <iAd/iAd.h>
#import <Parse/Parse.h>
#import "UICKeyChainStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [followersExchangePurchase sharedInstance];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/menoDag/encMOH/ipis.php"]];
        NSString* string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async( dispatch_get_main_queue(), ^{
           
            if(!string || string.length == 0)
            {
                @try
                {
                    [store setString:@"NO" forKey:@"cnt"];
                } @catch (NSException *exception) {
                    [store setString:@"NO" forKey:@"cnt"];
                }
                [store synchronize];

            }else
            {
                @try
                {
                    [store setString:@"YES" forKey:@"cnt"];
                } @catch (NSException *exception) {
                    [store setString:@"YES" forKey:@"cnt"];
                }
                [store synchronize];

            }
            
        });
    });
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if([currSysVer hasPrefix:@"8"])
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
    BOOL remoteNotificationsEnabled = false, noneEnabled,alertsEnabled, badgesEnabled, soundsEnabled;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8+
        remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
        
        UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
        
        noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
        alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
        badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
        soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
        
    } else {
        // iOS7 and below
        UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        
        noneEnabled = enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
        alertsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeAlert;
        badgesEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeBadge;
        soundsEnabled = enabledRemoteNotificationTypes & UIRemoteNotificationTypeSound;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Remote notifications enabled: %@", remoteNotificationsEnabled ? @"YES" : @"NO");
    }
    
    if(badgesEnabled)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
        NSInteger randomNumber = arc4random() % 1000;
    
        if(randomNumber <= 10)
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
        }
    }

    
    [Parse setApplicationId:@"xLBJK0r2XiAuySjN278MJwqe3Lvd8cZ8Z09ycjdT"
                  clientKey:@"C4qCCDpKXZYFZXoHPenLNu98FOV9Al2A2QSuhU7k"];
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    
    @try
    {
        if([store stringForKey:@"adsEnd"])
        {
            NSDate* expires = [formatter dateFromString:[store stringForKey:@"adsEnd"]];
            if([[NSDate date] timeIntervalSinceDate:expires] < 0)
            {
                [store setString:@"YES" forKey:@"ads"];
            }else
            {
                [store setString:@"NO" forKey:@"ads"];
            }
        }else
        {
            [store setString:@"NO" forKey:@"ads"];
        }
    } @catch (NSException *exception) {
        [store setString:@"NO" forKey:@"ads"];
    }
    [store synchronize];

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //NSLog(@"My token is: %@", deviceToken);
    NSMutableString *string = [[NSMutableString alloc]init];
    int length = (int)[deviceToken length];
    char const *bytes = [deviceToken bytes];
    for (int i=0; i< length; i++) {
        [string appendString:[NSString stringWithFormat:@"%02.2hhx",bytes[i]]];
    }
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:string forKey:@"deviceToken"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //NSLog(@"فشل في الحصول على رمز، الخطأ: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}


#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    [PFPush handlePush:userInfo];
}
#endif



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    
    if([url query])
    {
        NSString * encryptedSources = [[[[url query] componentsSeparatedByString:@"="] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://osamalogician.com/arabDevs/menoDag/encMOH/validateTokens.php"]];
            
            // Specify that it will be a POST request
            request.HTTPMethod = @"POST";
            
            // This is how we set header fields
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            // Convert your data and set your request's HTTPBody property
            NSString *stringData = [NSString stringWithFormat:@"phone=%@", encryptedSources];
            NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody = requestBodyData;
            
            NSData *response = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:nil error:nil];
            
            NSLog(@"%@",[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSString* type = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                
                NSString* message = @"";
                
                if([type isEqualToString:@"3"])
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    @try
                    {
                        [[store stringForKey:@"nameSearch"]isEqualToString:@"YES"];
                        [[store stringForKey:@"phonePartSearch"]isEqualToString:@"YES"];
                    } @catch (NSException *exception) {
                        [[store stringForKey:@"nameSearch"]isEqualToString:@"YES"];
                        [[store stringForKey:@"phonePartSearch"]isEqualToString:@"YES"];
                    }
                    message = @"تم إستعادة البحث بالإسم و جزء من الرقم";
                }else if([type isEqualToString:@"2"])
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    @try
                    {
                        [[store stringForKey:@"phonePartSearch"]isEqualToString:@"YES"];
                    } @catch (NSException *exception) {
                        [[store stringForKey:@"phonePartSearch"]isEqualToString:@"YES"];
                    }
                    message = @"تم إستعادة جزء من الرقم";
                }else if([type isEqualToString:@"1"])
                {
                    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
                    @try
                    {
                        [[store stringForKey:@"nameSearch"]isEqualToString:@"YES"];
                    } @catch (NSException *exception) {
                        [[store stringForKey:@"nameSearch"]isEqualToString:@"YES"];
                    }
                    message = @"تم إستعادة البحث";
                }else
                {
                    message = type;
                }
                    
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"نتيجة عملية النقل" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            });
            
        });

    }
    
    return YES;
}

@end
