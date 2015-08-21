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
#import <MMAdSDK/MMAdSDK.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIViewController prepareInterstitialAds];
    [followersExchangePurchase sharedInstance];
    
    [[MMSDK sharedInstance] initializeWithSettings:nil withUserSettings:nil];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if([currSysVer hasPrefix:@"8"])
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"numberOfNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSInteger randomNumber = arc4random() % 1000;
    
    [[MMSDK sharedInstance] initializeWithSettings:nil withUserSettings:nil];
    
    if(randomNumber <= 10)
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    }

    
    [Parse setApplicationId:@"xLBJK0r2XiAuySjN278MJwqe3Lvd8cZ8Z09ycjdT"
                  clientKey:@"C4qCCDpKXZYFZXoHPenLNu98FOV9Al2A2QSuhU7k"];

    
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


@end
