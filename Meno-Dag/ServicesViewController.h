//
//  ServicesViewController.h
//
//  Created by Housein Jouhar on 8/19/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicesViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *blockPriceText;
@property (strong, nonatomic) IBOutlet UILabel *namePriceText;
@property (strong, nonatomic) IBOutlet UILabel *partPriceText;
@property (weak, nonatomic) IBOutlet UILabel *adRemovePriceText;


@end
