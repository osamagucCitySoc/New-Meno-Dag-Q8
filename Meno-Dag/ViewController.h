//
//  ViewController.h
//  Meno-Dag
//
//  Created by Hussein Jouhar on 8/15/15.
//  Copyright (c) 2015 SADAH Software Solutions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

@interface ViewController : UIViewController <UIActionSheetDelegate>
{
    BOOL isTableVisible,isStopLoading,isLog,fromLog,isServices;
    NSMutableArray *savedLogNames,*savedLogNumbers;
    NSMutableData *responseData;
    NSURLConnection *getResultsConnection;
    NSArray *source;
    NSInteger currentInt;
}

@property (nonatomic, retain) MPAdView *adView;
@property (nonatomic, retain) MPInterstitialAdController *interstitial;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIImageView *largePhoneIcon;
@property (strong, nonatomic) IBOutlet UILabel *selectBack;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *searchSegment;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *resultsNavBar;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sectionsIcon;
@property (strong, nonatomic) IBOutlet UIImageView *logIcon;
@property (strong, nonatomic) IBOutlet UIImageView *searchIcon;
@property (strong, nonatomic) IBOutlet UIImageView *shareIcon;
@property (strong, nonatomic) IBOutlet UIImageView *cartIcon;
@property (strong, nonatomic) IBOutlet UIImageView *loadingBarImg;
@property (strong, nonatomic) IBOutlet UIImageView *loadingMagImg;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBarLabel;
@property (strong, nonatomic) IBOutlet UINavigationBar *logNavBar;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UIButton *emptyButton;
@property (strong, nonatomic) IBOutlet UIImageView *emptyImg;
@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;
@property (strong, nonatomic) IBOutlet UIImageView *shareImg;
@property (strong, nonatomic) IBOutlet UIView *aboutView;
@property (strong, nonatomic) IBOutlet UINavigationBar *aboutNavBar;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightsLabel;
@property (strong, nonatomic) IBOutlet UIToolbar *searchToolbar;

@end

