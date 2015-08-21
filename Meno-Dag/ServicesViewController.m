//
//  ServicesViewController.m
//
//  Created by Housein Jouhar on 8/19/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "ServicesViewController.h"
#import <AdSupport/AdSupport.h>
#import "followersExchangePurchase.h"

@interface ServicesViewController ()

@end

@implementation ServicesViewController
{
    NSArray* products;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 680);
    
    [self reload];
}

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
                }
            }
        }
    }];
}


- (IBAction)closeMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
