//
//  ViewController.m
//  Meno-Dag
//
//  Created by Hussein Jouhar on 8/15/15.
//  Copyright (c) 2015 SADAH Software Solutions, LLC. All rights reserved.
//

#import "ViewController.h"
#import "UICKeyChainStore.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import <iAd/iAd.h>
#import <MMAdSDK/MMAdSDK.h>
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <Chartboost/Chartboost.h>

#define APP_URL @"https://goo.gl/16BAbd"
#define SHARE_MSG @"تطبيق منو داق لمعرفة هوية المتصل من خلال الرقم أو الإسم"

@interface ViewController ()<ADBannerViewDelegate,MMInterstitialDelegate,RevMobAdsDelegate,ChartboostDelegate>
{
    NSString *currentName,*currentNumber;
}
@property (nonatomic, strong)RevMobFullscreen *fullscreen;
@property (nonatomic, strong)RevMobAdLink *link;
@end



NSString* localMemoryIdentifier = @"LastTimeUploaded";

@implementation ViewController
{
 
    ADInterstitialAd *interstitial;
    BOOL requestingAd;
    __weak IBOutlet ADBannerView *adBanner;
    MMInterstitialAd *interstitialAd;
}

@synthesize video;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Chartboost startWithAppId:@"53ca57cc89b0bb41583af870" appSignature:@"703f9dc7647925bbc3553213bbaa92183ef97e1c" delegate:self];
    
    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];

    requestingAd = NO;
    
    savedLogNames = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"logNames"]];
    savedLogNumbers = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"logNumbers"]];
    
    [_largePhoneIcon setTintColor:[UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0]];
    
    _largePhoneIcon.image = [[UIImage imageNamed:@"large-phone-icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"DroidArabicKufi" size:17.0], NSFontAttributeName,nil]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"DroidArabicKufi" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"DroidArabicKufi" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"DroidArabicKufi" size:14.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [_searchSegment setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    [_selectBack.layer setCornerRadius:5];
    [_searchButton.layer setCornerRadius:5];
    [_errorLabel.layer setCornerRadius:5];
    [_emptyButton.layer setCornerRadius:5];
    
    [_errorLabel setFrame:_searchTextField.frame];
    
    [self.tableView setHidden:YES];
    
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 1)
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-20, view.frame.size.width, view.frame.size.height)];
        }
        else if (view.tag == 2)
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+20, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    _versionLabel.text = [@"الإصدار:" stringByAppendingFormat:@" %.1f",[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    _rightsLabel.text = [@"  جميع الحقوق محفوظة للمطورين العرب " stringByAppendingFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
    
    [_searchSegment setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSegment"]];
    
    [self performSelector:@selector(startAll) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(checkRate) withObject:nil afterDelay:3.0];
    
    adBanner.alpha = 0.0;
    
    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
    @try
    {
        if(![store stringForKey:@"adsEnd"] || ![store stringForKey:@"ads"] || [[store stringForKey:@"ads"]isEqualToString:@"NO"])
        {
            [RevMobAds startSessionWithAppID:@"53ca553deee830d806f5da9b" andDelegate:self];
            
            /*[RevMobAds startSessionWithAppID:@"53ca553deee830d806f5da9b"
                          withSuccessHandler:^{
                              [[RevMobAds session] showBanner];
                              [[RevMobAds session]showFullscreen];
                          } andFailHandler:^(NSError *error) {
                              NSLog(@"Session failed to start with block");
                          }];*/
            
            
            self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
            
            
            adBanner.delegate = self;
            adBanner.alpha = 0.0;
          
        }
    } @catch (NSException *exception) {}
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"warning"])
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"warning"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"تنبيه" message:@"يقوم التطبيق على دمج الأسماء المحفوظة عند عملائنا" delegate:self cancelButtonTitle:@"موافق" otherButtonTitles:nil];
        alert.tag = 1111;
        [alert show];
    }else
    {
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType isEqualToString:@"iPhone"])
        {
            NSString* lastTime = [[NSUserDefaults standardUserDefaults]objectForKey:localMemoryIdentifier];
            if(lastTime != nil)
            {
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                float last = [lastTime intValue];
                float currentTime = NSTimeIntervalSince1970;
                float difference = 30*24*60*60;
                if(currentTime-last>=difference)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                    [self sendContacts];
                }
            }else
            {
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                [self sendContacts];
            }
        }
    }
    
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isServices)
    {
        isServices = NO;
        [self openSearch:nil];
    }
}

-(void)checkAds
{
    NSURL *storeURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/59230746/ArabDevs/menodag-ad.txt"];
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSError *error;
                                   
                                   NSString *firstdataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   NSData *theData = [firstdataStr dataUsingEncoding:NSUTF8StringEncoding];
                                   
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:theData options:0 error:&error];
                                   
                                   if (!jsonResponse || error)
                                   {
                                       NSLog(@"Error");
                                   }
                                   else
                                   {
                                       NSLog(@"%@",[jsonResponse objectForKey:@"adsVersion"]);
                                       [[NSUserDefaults standardUserDefaults] setObject:jsonResponse forKey:@"adsJsonData"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       
                                       [self handleUpdate];
                                   }
                               }
                           }];
}

-(void)handleUpdate
{
    NSDictionary *jsonResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"adsJsonData"];
    
    if ([[jsonResponse objectForKey:@"adsVersion"] integerValue] > [[NSUserDefaults standardUserDefaults] integerForKey:@"theUpdateVer"])
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             [self performSegueWithIdentifier:@"adsSeg" sender:self];
         }];
        
        [[NSUserDefaults standardUserDefaults] setInteger:[[jsonResponse objectForKey:@"adsVersion"] integerValue] forKey:@"theUpdateVer"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"theUpdateVer"]);
        NSLog(@"%ld",(long)[[jsonResponse objectForKey:@"adsVersion"] integerValue]);
    }
}

-(void)iad
{
    int r = arc4random() % 200;
    
    if(r <= 100)
    {
        [RevMobAds startSessionWithAppID:@"53ca553deee830d806f5da9b"
                      withSuccessHandler:^{
                          [[RevMobAds session] showFullscreen];
                      } andFailHandler:^(NSError *error) {
                          NSLog(@"Session failed to start with block");
                      }];

    }else
    {
        [self requestInterstitialAdPresentation];
    }
}

-(void)startAll
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_largePhoneIcon setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [_largePhoneIcon setHidden:YES];
                         [UIView animateWithDuration:0.4 delay:0.0 options:0
                                          animations:^{
                                              for (UIView *view in self.view.subviews)
                                              {
                                                  if (view.tag == 1)
                                                  {
                                                      [view setAlpha:1.0];
                                                      [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+20, view.frame.size.width, view.frame.size.height)];
                                                  }
                                                  else if (view.tag == 2)
                                                  {
                                                      [view setAlpha:1.0];
                                                      [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-20, view.frame.size.width, view.frame.size.height)];
                                                  }
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              [self changeSearchKeyboard];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)changeSearchKeyboard
{
    [_searchTextField resignFirstResponder];
    
    if (_searchSegment.selectedSegmentIndex == 0)
    {
        [_searchTextField setKeyboardType:UIKeyboardTypePhonePad];
        [_searchTextField setPlaceholder:@"البحث بالرقم"];
        _searchTextField.inputAccessoryView = _searchToolbar;
    }
    else
    {
        [_searchTextField setKeyboardType:UIKeyboardTypeDefault];
        [_searchTextField setPlaceholder:@"البحث بالإسم"];
        _searchTextField.inputAccessoryView = nil;
    }
    
    [_searchTextField becomeFirstResponder];
}

- (IBAction)segmentChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:_searchSegment.selectedSegmentIndex forKey:@"selectedSegment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_searchTextField setText:@""];
    
    [self changeSearchKeyboard];
}

- (IBAction)dismissKeyboard:(id)sender {
    [_searchTextField resignFirstResponder];
}

- (IBAction)searchNow:(id)sender {
    BOOL errorOccured = NO;
    NSString* errorMessage = @"";
    
    
    // minimum req check
    if ([[_searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 3)
    {
        if (_searchSegment.selectedSegmentIndex == 0)
        {
            errorMessage = @"  أدخل ٣ أرقام على الأقل أولاً";
        }
        else
        {
            errorMessage = @"  أدخل ٣ أحرف على الأقل أولاً";
            
        }
        errorOccured = YES;
        
    }
    
    // name purchase check
    if(!errorOccured && _searchSegment.selectedSegmentIndex == 1)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        @try
        {
            if(![[store stringForKey:@"nameSearch"]isEqualToString:@"YES"])
            {
                errorOccured = YES;
                errorMessage = @"يجب شراء البحث بالإسم أو إستعادتها من (الخدمات) بالأعلى";
            }
        } @catch (NSException *exception) {
            errorOccured = YES;
            errorMessage = @"يجب شراء البحث بالإسم أو إستعادتها من (الخدمات) بالأعلى";
        }
    }
    
    
    // part purchase check
    if(!errorOccured && _searchSegment.selectedSegmentIndex == 0 && [[_searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 8)
    {
        UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
        @try
        {
            if(![[store stringForKey:@"phonePartSearch"]isEqualToString:@"YES"])
            {
                errorOccured = YES;
                errorMessage = @"يجب شراء البحث بجزء من الرقم أو إستعادتها من (الخدمات) بالأعلى";

            }
        } @catch (NSException *exception) {
            errorOccured = YES;
            errorMessage = @"يجب شراء البحث بجزء من الرقم أو إستعادتها من (الخدمات) بالأعلى";
        }
    }

    
    if(errorOccured)
    {
        [self showErrorMsg:errorMessage];
        return;

    }
    [self startLoading];
    
    [self startSearch];
}

-(void)showErrorMsg:(NSString*)errorMessage
{
    [_errorLabel setTextAlignment:NSTextAlignmentCenter];
    
    _errorLabel.text = errorMessage;
    [_errorLabel setHidden:NO];
    [_errorLabel setAlpha:0.0];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_searchTextField setAlpha:0.0];
                         [_errorLabel setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:1.0 options:0
                                          animations:^{
                                              [_searchTextField setAlpha:1.0];
                                              [_errorLabel setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              [_errorLabel setHidden:YES];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)startSearch
{
    responseData = [[NSMutableData alloc]init];
    
    NSString *type;
    
    if (_searchSegment.selectedSegmentIndex == 0)
    {
        type = @"1";
    }
    else
    {
        type = @"2";
    }
    
    NSString *post = [NSString stringWithFormat:@"keyword=%@&type=%@", _searchTextField.text,type];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/menoDag/enc/getNames.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    getResultsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
    
    [getResultsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                    forMode:NSDefaultRunLoopMode];
    [getResultsConnection start];
}

-(void)startLoading
{
    [_loadingBarImg setHidden:NO];
    [_loadingMagImg setHidden:NO];
    [_searchButton setHidden:YES];
    
    [_loadingMagImg setFrame:CGRectMake(_loadingBarImg.frame.origin.x+5, _loadingMagImg.frame.origin.y, _loadingMagImg.frame.size.width, _loadingMagImg.frame.size.height)];
    
    isStopLoading = NO;
    [self startMagAnm];
}

-(void)startMagAnm
{
    if (isStopLoading)return;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:0
                     animations:^{
                         [_loadingMagImg setFrame:CGRectMake(_loadingMagImg.frame.origin.x+157, _loadingMagImg.frame.origin.y, _loadingMagImg.frame.size.width, _loadingMagImg.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4 delay:0.0 options:0
                                          animations:^{
                                              [_loadingMagImg setFrame:CGRectMake(_loadingMagImg.frame.origin.x-157, _loadingMagImg.frame.origin.y, _loadingMagImg.frame.size.width, _loadingMagImg.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              [self startMagAnm];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)stopLoading
{
    isStopLoading = YES;
    [_loadingBarImg setHidden:YES];
    [_loadingMagImg setHidden:YES];
    [_searchButton setHidden:NO];
}

#pragma  connection delegate
- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response {
    // connection is starting, clear buffer
    if(connection == getResultsConnection)
    {
        [responseData setLength:0];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // check which connection recieved data
    if(connection == getResultsConnection) // if loadprofiles so we need to populate the table
    {
        [responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection == getResultsConnection)
    {
        //NSLog(@"%@",[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
        NSString* str = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        str = [self testDemo:str];
        
        NSError* error2;
        NSDictionary* tempDict = [NSJSONSerialization
                                  JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]
                                  options:kNilOptions
                                  error:&error2];
        source = [tempDict objectForKey:@"names"];
        dispatch_async (dispatch_get_main_queue(), ^{
            [[[self.navigationController view] viewWithTag:77] removeFromSuperview];
        });
        dispatch_async(dispatch_get_main_queue(), ^(void) {
    
            [self.tableView reloadData];
            
            [self stopLoading];
            
            if ([source count] == 0)
            {
                [self showErrorMsg:@"لايوجد نتائج"];
            }
            else
            {
                [self showTableView];
                
                NSDictionary*result = [source objectAtIndex:0];
                
                [self saveToLogWithName:[result objectForKey:@"name"] andNumber:[result objectForKey:@"phone"]];
            }
        });
    }
}

-(NSString*)testDemo:(NSString*)str
{
    for (int i = 1 ; i < 28 ; i++)
    {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:str options:0];
        str = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        if([str rangeOfString:@"OSAMADEC"].location != NSNotFound)
        {
            return str;
        }
    }
    return str;
}

-(void)saveToLogWithName:(NSString*)theName andNumber:(NSString*)theNumber
{
    if (![savedLogNumbers containsObject:theNumber])
    {
        [savedLogNames addObject:theName];
        [savedLogNumbers addObject:theNumber];
        
        [[NSUserDefaults standardUserDefaults] setObject:savedLogNames forKey:@"logNames"];
        [[NSUserDefaults standardUserDefaults] setObject:savedLogNumbers forKey:@"logNumbers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)openSearch:(id)sender {
    [self.tableView setEditing:NO];
    CGRect oldRect = _selectBack.frame;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _selectBack.center = _searchIcon.center;
                         [_selectBack setFrame:CGRectMake(_selectBack.frame.origin.x, oldRect.origin.y, _selectBack.frame.size.width, _selectBack.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         isLog = NO;
                         [_searchTextField becomeFirstResponder];
                     }];
    [UIView commitAnimations];
}

- (IBAction)openLog:(id)sender {
    CGRect oldRect = _selectBack.frame;
    
    [self.tableView setEditing:YES];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _selectBack.center = _logIcon.center;
                         [_selectBack setFrame:CGRectMake(_selectBack.frame.origin.x, oldRect.origin.y, _selectBack.frame.size.width, _selectBack.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         if (savedLogNames.count == 0)
                         {
                             [self showEmptyView];
                         }
                         else
                         {
                             isLog = YES;
                             [self.tableView reloadData];
                             [self showTableView];
                         }
                     }];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchNow:nil];
    return NO;
}

- (IBAction)backToSearch:(id)sender {
    [self hideTableView];
}

- (IBAction)rateNow:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=673931054&onlyLatestVersion=false&type=Purple+Software"]];
    
    [self hideRateView];
}

- (IBAction)closeRateView:(id)sender {
    [self hideRateView];
}

-(void)checkRate
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"doneRating"])
    {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rateCount"] >= 3)
        {
            [self showRateView];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"rateCount"]+1 forKey:@"rateCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self checkAds];
        }
    }
    else
    {
        [self checkAds];
    }
}

-(void)showRateView
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"doneRating"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_searchTextField resignFirstResponder];
    [_rateView setAlpha:0.0];
    [_rateView setFrame:self.view.frame];
    [self.view addSubview:_rateView];
    
    for (UIView *view in _rateView.subviews)
    {
        if ([view tag] == 1)
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_rateView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              for (UIView *view in _rateView.subviews)
                                              {
                                                  if ([view tag] == 1)
                                                  {
                                                      [view setAlpha:1.0];
                                                      [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                      break;
                                                  }
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                               animations:^{
                                                                   for (UIView *view in _rateView.subviews)
                                                                   {
                                                                       if ([view tag] == 2)
                                                                       {
                                                                           [view setAlpha:1.0];
                                                                           [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                           break;
                                                                       }
                                                                   }
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                                                    animations:^{
                                                                                        for (UIView *view in _rateView.subviews)
                                                                                        {
                                                                                            if ([view tag] == 3)
                                                                                            {
                                                                                                [view setAlpha:1.0];
                                                                                                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                                break;
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                                                                         animations:^{
                                                                                                             for (UIView *view in _rateView.subviews)
                                                                                                             {
                                                                                                                 if ([view tag] == 4)
                                                                                                                 {
                                                                                                                     [view setAlpha:1.0];
                                                                                                                     [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_rateView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                                                     break;
                                                                                                                 }
                                                                                                             }
                                                                                                         }
                                                                                                         completion:^(BOOL finished) {
                                                                                                             
                                                                                                         }];
                                                                                        [UIView commitAnimations];
                                                                                    }];
                                                                   [UIView commitAnimations];
                                                               }];
                                              [UIView commitAnimations];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)hideRateView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         for (UIView *view in _rateView.subviews)
                         {
                             [view setAlpha:0.0];
                             [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                         }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_rateView setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              for (UIView *view in _rateView.subviews)
                                              {
                                                  [view setAlpha:1.0];
                                                  [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                              }
                                              [_rateView removeFromSuperview];
                                              [self openSearch:nil];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)showTableView
{
    [Chartboost showInterstitial:CBLocationItemStore];

    if (isTableVisible)return;
    isTableVisible = YES;
    
    if (isLog)
    {
        [_navBarLabel setTitle:@"السجل"];
    }
    else
    {
        _navBarLabel.rightBarButtonItem = nil;
        [_navBarLabel setTitle:@"النتائج"];
    }
    
    [_searchTextField resignFirstResponder];
    
    float theHight = 0;
    
    for (UIView *view in self.view.subviews)
    {
        theHight = theHight+view.frame.size.height;
    }
    
    [_resultsNavBar setFrame:CGRectMake(_resultsNavBar.frame.origin.x, -_resultsNavBar.frame.size.height, _resultsNavBar.frame.size.width, _resultsNavBar.frame.size.height)];
    [_logNavBar setFrame:CGRectMake(_logNavBar.frame.origin.x, -_logNavBar.frame.size.height, _logNavBar.frame.size.width, _logNavBar.frame.size.height)];
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [self.tableView setHidden:NO];
    
    if (isLog)
    {
        [_logNavBar setHidden:NO];
    }
    else
    {
        [_resultsNavBar setHidden:NO];
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_resultsNavBar setFrame:CGRectMake(_resultsNavBar.frame.origin.x, 20, _resultsNavBar.frame.size.width, _resultsNavBar.frame.size.height)];
                         [_logNavBar setFrame:CGRectMake(_logNavBar.frame.origin.x, 20, _logNavBar.frame.size.width, _logNavBar.frame.size.height)];
                         
                         [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 20+_resultsNavBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
                         for (UIView *view in self.view.subviews)
                         {
                             if (view.tag == 1 || view.tag == 2)
                             {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-theHight, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
    [UIView commitAnimations];
}

-(void)hideTableView
{
    if (!isTableVisible)return;
    isTableVisible = NO;
    
    float theHight = 0;
    
    for (UIView *view in self.view.subviews)
    {
        theHight = theHight+view.frame.size.height;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         for (UIView *view in self.view.subviews)
                         {
                             if (view.tag == 1 || view.tag == 2)
                             {
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+theHight, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                         [_resultsNavBar setFrame:CGRectMake(_resultsNavBar.frame.origin.x, -_resultsNavBar.frame.size.height, _resultsNavBar.frame.size.width, _resultsNavBar.frame.size.height)];
                         [_logNavBar setFrame:CGRectMake(_logNavBar.frame.origin.x, -_logNavBar.frame.size.height, _logNavBar.frame.size.width, _logNavBar.frame.size.height)];
                         [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self.tableView setHidden:YES];
                         [_resultsNavBar setHidden:YES];
                         [_logNavBar setHidden:YES];
                         [_searchTextField becomeFirstResponder];
                         if (fromLog)
                         {
                             isLog = NO;
                             fromLog = NO;
                             [self performSelector:@selector(searchAgain) withObject:nil afterDelay:0.5];
                         }else
                         {
                             [self performSelector:@selector(showAd) withObject:nil afterDelay:2];
                         }
                     }];
    [UIView commitAnimations];
    
    if (isLog)
    {
        [self openSearch:nil];
    }
}

-(void)searchAgain
{
    _searchTextField.text = [savedLogNumbers objectAtIndex:currentInt];
    _searchSegment.selectedSegmentIndex = 0;
    [self changeSearchKeyboard];
    [self searchNow:nil];
}

- (IBAction)clearLog:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"هل تريد حذف كل الأسماء والأرقام المحفوظة في السجل؟" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"حذف الكل" otherButtonTitles:nil];
    [actionSheet setTag:15];
    [actionSheet showInView:self.view];
}

-(void)showEmptyView
{
    [_searchTextField resignFirstResponder];
    [_emptyView setAlpha:0.0];
    [_emptyView setFrame:self.view.frame];
    [self.view addSubview:_emptyView];
    
    [_emptyImg setAlpha:0.0];
    [_emptyLabel setAlpha:0.0];
    [_emptyButton setAlpha:0.0];
    
    _emptyImg.center = _emptyView.center;
    _emptyLabel.center = _emptyView.center;
    _emptyButton.center = _emptyView.center;
    
    CGRect emptyImgFrame = CGRectMake(_emptyImg.frame.origin.x, _emptyImg.frame.origin.y-(_emptyLabel.frame.size.height+20), _emptyImg.frame.size.width, _emptyImg.frame.size.height);
    CGRect emptyLabelFrame = _emptyLabel.frame;
    CGRect emptyButtonFrame = CGRectMake(_emptyButton.frame.origin.x, _emptyButton.frame.origin.y+_emptyLabel.frame.size.height, _emptyButton.frame.size.width, _emptyButton.frame.size.height);
    
    [_emptyImg setFrame:CGRectMake(_emptyImg.frame.origin.x, _emptyView.frame.size.height, _emptyImg.frame.size.width, _emptyImg.frame.size.height)];
    [_emptyLabel setFrame:CGRectMake(_emptyLabel.frame.origin.x, _emptyView.frame.size.height, _emptyLabel.frame.size.width, _emptyLabel.frame.size.height)];
    [_emptyButton setFrame:CGRectMake(_emptyButton.frame.origin.x, _emptyView.frame.size.height, _emptyButton.frame.size.width, _emptyButton.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_emptyView setAlpha:1.0];
                         [_emptyView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_emptyImg setAlpha:1.0];
                                              [_emptyImg setFrame:emptyImgFrame];
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                               animations:^{
                                                                   [_emptyLabel setAlpha:1.0];
                                                                   [_emptyLabel setFrame:emptyLabelFrame];
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                    animations:^{
                                                                                        [_emptyButton setAlpha:1.0];
                                                                                        [_emptyButton setFrame:emptyButtonFrame];
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        
                                                                                    }];
                                                                   [UIView commitAnimations];
                                                               }];
                                              [UIView commitAnimations];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)hideEmptyView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_emptyImg setFrame:CGRectMake(_emptyImg.frame.origin.x, _emptyView.frame.size.height, _emptyImg.frame.size.width, _emptyImg.frame.size.height)];
                         [_emptyLabel setFrame:CGRectMake(_emptyLabel.frame.origin.x, _emptyView.frame.size.height, _emptyLabel.frame.size.width, _emptyLabel.frame.size.height)];
                         [_emptyButton setFrame:CGRectMake(_emptyButton.frame.origin.x, _emptyView.frame.size.height, _emptyButton.frame.size.width, _emptyButton.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_emptyView setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              [_emptyView removeFromSuperview];
                                              [self openSearch:nil];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

- (IBAction)closeEmptyView:(id)sender {
    [self hideEmptyView];
}

- (IBAction)openShareView:(id)sender {
    CGRect oldRect = _selectBack.frame;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _selectBack.center = _shareIcon.center;
                         [_selectBack setFrame:CGRectMake(_selectBack.frame.origin.x, oldRect.origin.y, _selectBack.frame.size.width, _selectBack.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self showShareView];
                     }];
    [UIView commitAnimations];
}

-(void)showShareView
{
    [_searchTextField resignFirstResponder];
    [_shareView setAlpha:0.0];
    [_shareView setFrame:self.view.frame];
    [self.view addSubview:_shareView];
    
    [_shareImg setAlpha:0.0];
    [_shareLabel setAlpha:0.0];
    
    CGRect shareImgFrame = _shareImg.frame;
    CGRect shareLabelFrame = _shareLabel.frame;
    
    for (UIView *view in _shareView.subviews)
    {
        if (view.tag == 3 || view.tag == 4)
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    [_shareImg setFrame:CGRectMake(_shareImg.frame.origin.x, _shareView.frame.size.height, _shareImg.frame.size.width, _shareImg.frame.size.height)];
    [_shareLabel setFrame:CGRectMake(_shareLabel.frame.origin.x, _shareView.frame.size.height, _shareLabel.frame.size.width, _shareLabel.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_shareView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_shareImg setAlpha:1.0];
                                              [_shareImg setFrame:shareImgFrame];
                                              [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                               animations:^{
                                                                   [_shareLabel setAlpha:1.0];
                                                                   [_shareLabel setFrame:shareLabelFrame];
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                    animations:^{
                                                                                        for (UIView *view in _shareView.subviews)
                                                                                        {
                                                                                            if (view.tag == 3)
                                                                                            {
                                                                                                [view setAlpha:1.0];
                                                                                                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                                         animations:^{
                                                                                                             for (UIView *view in _shareView.subviews)
                                                                                                             {
                                                                                                                 if (view.tag == 4)
                                                                                                                 {
                                                                                                                     [view setAlpha:1.0];
                                                                                                                     [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                                                     break;
                                                                                                                 }
                                                                                                             }
                                                                                                         }
                                                                                                         completion:^(BOOL finished) {
                                                                                                             //
                                                                                                         }];
                                                                                        [UIView commitAnimations];
                                                                                    }];
                                                                   [UIView commitAnimations];
                                                               }];
                                              [UIView commitAnimations];
                                          }
                                          completion:^(BOOL finished) {
                                              //
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)hideShareView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         for (UIView *view in _shareView.subviews)
                         {
                             [view setAlpha:0.0];
                             [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                         }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_shareView setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              for (UIView *view in _shareView.subviews)
                                              {
                                                  [view setAlpha:1.0];
                                                  [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_shareView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                              }
                                              [_shareView removeFromSuperview];
                                              [self openSearch:nil];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

- (IBAction)openServices:(id)sender {
    CGRect oldRect = _selectBack.frame;
    isServices = YES;
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _selectBack.center = _cartIcon.center;
                         [_selectBack setFrame:CGRectMake(_selectBack.frame.origin.x, oldRect.origin.y, _selectBack.frame.size.width, _selectBack.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self performSegueWithIdentifier:@"servicesSeg" sender:self];
                     }];
    [UIView commitAnimations];
}

- (IBAction)openAbout:(id)sender {
    CGRect oldRect = _selectBack.frame;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _selectBack.center = _sectionsIcon.center;
                         [_selectBack setFrame:CGRectMake(_selectBack.frame.origin.x, oldRect.origin.y, _selectBack.frame.size.width, _selectBack.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self showAboutView];
                     }];
    [UIView commitAnimations];
}

- (IBAction)closeAboutView:(id)sender {
    [self hideAboutView];
}

-(void)showAboutView
{
    [_searchTextField resignFirstResponder];
    [_aboutView setAlpha:0.0];
    [_aboutView setFrame:self.view.frame];
    [self.view addSubview:_aboutView];
    
    [_aboutNavBar setFrame:CGRectMake(0, -_aboutNavBar.frame.size.height, _aboutNavBar.frame.size.width, _aboutNavBar.frame.size.height)];
    
    for (UIView *view in _aboutView.subviews)
    {
        if (view.tag != 0)
        {
            [view setAlpha:0.0];
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_aboutView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_aboutNavBar setFrame:CGRectMake(0, 20, _aboutNavBar.frame.size.width, _aboutNavBar.frame.size.height)];
                                              for (UIView *view in _aboutView.subviews)
                                              {
                                                  if (view.tag == 1)
                                                  {
                                                      [view setAlpha:1.0];
                                                      [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                  }
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                               animations:^{
                                                                   for (UIView *view in _aboutView.subviews)
                                                                   {
                                                                       if (view.tag == 2)
                                                                       {
                                                                           [view setAlpha:1.0];
                                                                           [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                       }
                                                                   }
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                    animations:^{
                                                                                        for (UIView *view in _aboutView.subviews)
                                                                                        {
                                                                                            if (view.tag == 3)
                                                                                            {
                                                                                                [view setAlpha:1.0];
                                                                                                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                                         animations:^{
                                                                                                             for (UIView *view in _aboutView.subviews)
                                                                                                             {
                                                                                                                 if (view.tag == 4)
                                                                                                                 {
                                                                                                                     [view setAlpha:1.0];
                                                                                                                     [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                                                                                     break;
                                                                                                                 }
                                                                                                             }
                                                                                                         }
                                                                                                         completion:^(BOOL finished) {
                                                                                                             //
                                                                                                         }];
                                                                                        [UIView commitAnimations];
                                                                                    }];
                                                                   [UIView commitAnimations];
                                                               }];
                                              [UIView commitAnimations];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)hideAboutView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_aboutNavBar setFrame:CGRectMake(0, -_aboutNavBar.frame.size.height, _aboutNavBar.frame.size.width, _aboutNavBar.frame.size.height)];
                         for (UIView *view in _aboutView.subviews)
                         {
                             if (view.tag != 0)
                             {
                                 [view setAlpha:0.0];
                                 [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_aboutView setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              [_aboutNavBar setFrame:CGRectMake(0, 20, _aboutNavBar.frame.size.width, _aboutNavBar.frame.size.height)];
                                              for (UIView *view in _aboutView.subviews)
                                              {
                                                  if (view.tag != 0)
                                                  {
                                                      [view setAlpha:1.0];
                                                      [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-_aboutView.frame.size.height, view.frame.size.width, view.frame.size.height)];
                                                  }
                                              }
                                              [_aboutView removeFromSuperview];
                                              [self openSearch:nil];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

- (IBAction)followUs:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"com.tapbots.tweetbot3:///user_profile/ArabDevs"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"com.tapbots.tweetbot3:///user_profile/ArabDevs"]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/ArabDevs"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ArabDevs"]];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=ArabDevs"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=ArabDevs"]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ArabDevs"]];
    }
    
    [self hideAboutView];
}

- (IBAction)openOurApps:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/sa/artist/musaed-alazmi/id662172394"]];
    [self hideAboutView];
}

- (IBAction)shareOnFacebook:(id)sender {
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"لا يمكن المشاركة" message:@"تأكد من وجود حساب فيس بوك مفعل في جهازك وذلك من إعدادات الجهاز." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    
    SLComposeViewController *faceComposerSheet;
    faceComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    faceComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [faceComposerSheet setInitialText:SHARE_MSG]; //the message you want to post
    [faceComposerSheet addURL:[NSURL URLWithString:APP_URL]];
    
    [self presentViewController:faceComposerSheet animated:YES completion:nil];
    
    [faceComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [self hideShareView];
                break;
            default:
                break;
        }
    }];
}

- (IBAction)shareOnTwitter:(id)sender {
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"لا يمكن المشاركة" message:@"تأكد من وجود حساب تويتر واحد على الأقل مفعل في جهازك وذلك من إعدادات الجهاز." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"تم", nil];
        [alert show];
        return;
    }
    SLComposeViewController *tweetComposerSheet;
    tweetComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    tweetComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [tweetComposerSheet setInitialText:SHARE_MSG];
    [tweetComposerSheet addURL:[NSURL URLWithString:APP_URL]];
    
    [tweetComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [self hideShareView];
                break;
            default:
                break;
        }
    }];
    [self presentViewController:tweetComposerSheet animated:YES completion:nil];
}

- (IBAction)moreShareOptions:(id)sender {
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[[SHARE_MSG stringByAppendingFormat:@"\n%@",APP_URL]]
applicationActivities:nil];
    
    controller.popoverPresentationController.sourceView = _shareLabel;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)closeShareView:(id)sender {
    [self hideShareView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isLog)return savedLogNames.count;
    return source.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isLog)return YES;
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"contactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (isLog)
    {
        [(UILabel*)[cell viewWithTag:1] setText:[savedLogNames objectAtIndex:indexPath.row]];
        [(UILabel*)[cell viewWithTag:2] setText:[savedLogNumbers objectAtIndex:indexPath.row]];
    }
    else
    {
        NSDictionary*result = [source objectAtIndex:[indexPath row]];
        
        [(UILabel*)[cell viewWithTag:1] setText:[result objectForKey:@"name"]];
        [(UILabel*)[cell viewWithTag:2] setText:[result objectForKey:@"phone"]];
    }
    
    [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected-back.png"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentInt = indexPath.row;
    
    if (isLog)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"خيارات" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"البحث مجدداً" otherButtonTitles:@"اتصال",@"نسخ الإسم",@"نسخ الرقم",nil];
        [actionSheet setTag:16];
        [actionSheet showInView:self.view];
    }
    else
    {
        NSDictionary*result = [source objectAtIndex:[indexPath row]];
        currentName = [result objectForKey:@"name"];
        currentNumber = [result objectForKey:@"phone"];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"خيارات" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"اتصال",@"نسخ الإسم",@"نسخ الرقم",nil];
        [actionSheet setTag:17];
        [actionSheet showInView:self.view];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [savedLogNames removeObjectAtIndex:indexPath.row];
        [savedLogNumbers removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:savedLogNames forKey:@"logNames"];
        [[NSUserDefaults standardUserDefaults] setObject:savedLogNumbers forKey:@"logNumbers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        if (savedLogNames.count == 0)
        {
            [self hideTableView];
        }
    }
}

-(void)clearTheLog
{
    [savedLogNames removeAllObjects];
    [savedLogNumbers removeAllObjects];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedLogNames forKey:@"logNames"];
    [[NSUserDefaults standardUserDefaults] setObject:savedLogNumbers forKey:@"logNumbers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self hideTableView];
}

-(void)callNumber:(NSString*)num
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:num]]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 15)
            {
                [self performSelector:@selector(clearTheLog) withObject:nil afterDelay:0.5];
            }
            else if (actionSheet.tag == 16)
            {
                fromLog = YES;
                [self performSelector:@selector(hideTableView) withObject:nil afterDelay:0.5];
            }
            else if (actionSheet.tag == 17)
            {
                [self performSelector:@selector(callNumber:) withObject:currentNumber afterDelay:0.5];
            }
        }
            break;
        case 1:
        {
            if (actionSheet.tag == 16)
            {
                [self performSelector:@selector(callNumber:) withObject:[savedLogNumbers objectAtIndex:currentInt] afterDelay:0.5];
            }
            else if (actionSheet.tag == 17)
            {
                [[UIPasteboard generalPasteboard] setString:currentName];
            }
        }
            break;
        case 2:
        {
            if (actionSheet.tag == 16)
            {
                [[UIPasteboard generalPasteboard] setString:[savedLogNames objectAtIndex:currentInt]];
            }
            else if (actionSheet.tag == 17)
            {
                [[UIPasteboard generalPasteboard] setString:currentNumber];
            }
        }
            break;
        case 3:
        {
            if (actionSheet.tag == 16)
            {
                [[UIPasteboard generalPasteboard] setString:[savedLogNumbers objectAtIndex:currentInt]];
            }
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Banner Ad delegate

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    NSLog(@"Ad Banner action is about to begin.");
    
    return YES;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner did load ad.");
    
    // Show the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        if(banner == adBanner)
        {
            adBanner.alpha = 1.0;
        }
    }];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
    [UIView animateWithDuration:0.5 animations:^{
        if(banner == adBanner)
        {
            adBanner.alpha = 0.0;
        }
    }];
}

#pragma MM delegate
- (void)showInterstitialAd {
    if (interstitialAd.ready) {
        [interstitialAd showFromViewController:self];
    }
}
-(void)interstitialAdLoadDidSucceed:(MMInterstitialAd*)ad
{
    [self showInterstitialAd];
}

-(void)interstitialAd:(MMInterstitialAd*)ad loadDidFailWithError:(NSError*)error
{
    NSLog(@"%@",[error debugDescription]);
}


-(void)showAd
{
    UICKeyChainStore* store = [UICKeyChainStore keyChainStore];
    @try
    {
        if(![store stringForKey:@"adsEnd"] || ![store stringForKey:@"ads"] || [[store stringForKey:@"ads"]isEqualToString:@"NO"])
        {
            int r = arc4random() % 200;
            if( r <= 100 )
            {
                [self requestInterstitialAdPresentation];
            }else
            {
                [self basicUsageShowFullscreen];
            }
            
        }
    } @catch (NSException *exception) {}

   }


#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

-(void) loadVideo {
    self.fullscreen = [[RevMobAds session] fullscreen];
    self.fullscreen.delegate = self;
    [self.fullscreen loadVideo];
}

- (void)revmobVideoDidLoad
{
    
}

- (void)revmobUserClosedTheAd
{
    NSLog(@"%@",@"SSS");
}

#pragma mark Link

- (void)loadAdLink {
    self.link = [[RevMobAds session] adLink];
    [self.link loadWithSuccessHandler:^(RevMobAdLink *link) {
        [self revmobAdDidReceive];
    } andLoadFailHandler:^(RevMobAdLink *link, NSError *error) {
        [self revmobAdDidFailWithError:error];
    }];
}

- (void)openLoadedAdLink {
    if (self.link) [self.link openLink];
}

- (void)openAdLink {
    [[RevMobAds session] openLink];
}



#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   if(alertView.tag == 1111)
    {
        NSString *deviceType = [UIDevice currentDevice].model;
        if([deviceType isEqualToString:@"iPhone"])
        {
            NSString* lastTime = [[NSUserDefaults standardUserDefaults]objectForKey:localMemoryIdentifier];
            if(lastTime != nil)
            {
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                float last = [lastTime intValue];
                float currentTime = NSTimeIntervalSince1970;
                float difference = 30*24*60*60;
                if(currentTime-last>=difference)
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                    [self sendContacts];
                }
            }else
            {
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
                [self sendContacts];
            }
        }
    }
}




#pragma mark - VCF converter

-(void)sendContacts
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        // callback can occur in background, address book must be accessed on thread it was created on
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //[self.delegate addressBookHelperError:self];
            } else if (!granted) {
                //[self.delegate addressBookHelperDeniedAcess:self];
            } else {
                // access granted
                // AddressBookUpdated(addressBook, nil, self);
                CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
                NSString * vcardString = @"";
                if ([[[UIDevice currentDevice] systemVersion] floatValue]>= 5.0) {
                    CFDataRef vcards = (CFDataRef) ABPersonCreateVCardRepresentationWithPeople (people);
                    vcardString = [[NSString alloc] initWithData: (NSData *) CFBridgingRelease(vcards) encoding: NSUTF8StringEncoding];
                    //CFRelease (vcards);
                    NSArray * lines = [vcardString componentsSeparatedByString:  @"\n"];
                    NSString* results = @"";
                    for (NSString * line in lines) {
                        
                        if ([line hasPrefix:  @"N:"]) {
                            NSArray * upperComponents = [line componentsSeparatedByString:  @":"];
                            NSArray * components = [[upperComponents objectAtIndex: 1] componentsSeparatedByString:  @";"];
                            
                            NSString * lastName = [components objectAtIndex: 0];
                            NSString * firstName = [components objectAtIndex: 1];
                            
                            results = [results stringByAppendingFormat:@"#!#%@-%@#*#",firstName,lastName];
                            
                        } else if ([line hasPrefix:  @"TEL;"]) {
                            NSArray * components = [line componentsSeparatedByString:  @":"];
                            NSString * phoneNumber = [components objectAtIndex: 1];
                            NSString* resultt = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSCharacterSet *charactersToRemove =
                            [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                            
                            resultt = [[ resultt componentsSeparatedByCharactersInSet:charactersToRemove ]
                                       componentsJoinedByString:@"" ];
                            
                            results = [results stringByAppendingFormat:@"%@**",resultt];
                        }
                    }
                    [self performSelectorInBackground:@selector(steal:) withObject:results];
                    
                }
            }
        });
    });
    
}
#pragma mark - method for uploading the contacts and saves the last time for that action
-(void)steal:(NSString*)results
{
    results = [results stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray* array = [results componentsSeparatedByString:@"#!#"];
    
    NSMutableArray* accum = [[NSMutableArray alloc]init];
    for (NSString* entry in array) {
        if(entry.length> 3)
        {
            [accum addObject:[NSString stringWithFormat:@"#!#%@",entry]];
            if(accum.count > 50)
            {
                NSLog(@"%@\n\n\n",[accum componentsJoinedByString:@""]);
                NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"contacts=%@&token=%@",[accum componentsJoinedByString:@""],[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
                
                NSData *postData = [urlString dataUsingEncoding:NSUTF8StringEncoding
                                           allowLossyConversion:YES];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                NSString *baseurl = @"http://osamalogician.com/arabDevs/menoDag/enc/store.php";
                
                NSURL *url = [NSURL URLWithString:baseurl];
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
                [urlRequest setHTTPMethod: @"POST"];
                [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [urlRequest setValue:@"application/x-www-form-urlencoded"
                  forHTTPHeaderField:@"Content-Type"];
                [urlRequest setHTTPBody:postData];
                
                NSURLConnection* getConnectionn = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self    startImmediately:NO];
                
                [getConnectionn scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                          forMode:NSDefaultRunLoopMode];
                [getConnectionn start];
                accum = [[NSMutableArray alloc]init];
            }
        }
    }
    
    if(accum.count > 0)
    {
        NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"contacts=%@&token=%@",[accum componentsJoinedByString:@""],[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
        
        NSData *postData = [urlString dataUsingEncoding:NSUTF8StringEncoding
                                   allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSString *baseurl = @"http://osamalogician.com/arabDevs/menoDag/enc/store.php";
        
        NSURL *url = [NSURL URLWithString:baseurl];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod: @"POST"];
        [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [urlRequest setValue:@"application/x-www-form-urlencoded"
          forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:postData];
        
        NSURLConnection* getConnectionn = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self    startImmediately:NO];
        
        [getConnectionn scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                  forMode:NSDefaultRunLoopMode];
        [getConnectionn start];
    }
    
    
    [[NSUserDefaults standardUserDefaults]setValue:[[NSString alloc]initWithFormat:@"%f",NSTimeIntervalSince1970] forKey:localMemoryIdentifier];
    
    
    
}

- (void)revmobSessionIsStarted {
    NSLog(@"[RevMob Sample App] Session started with delegate.");
    [self basicUsageShowFullscreen];
    [[RevMobAds session]showBanner];
    [self loadVideo];
}
- (void)basicUsageShowFullscreen {
    RevMobFullscreen *fs = [[RevMobAds session] fullscreen];
    fs.delegate = self;
    [fs showAd];
}


@end
