//
//  ViewController.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic,strong) IBOutlet UILabel* shapeLabel1;
@property (nonatomic,strong) IBOutlet UILabel* shapeLabel2;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) IBOutlet UIView* square50x50;
@property (nonatomic,strong) IBOutlet UIView* square75x75;
@property (nonatomic,strong) IBOutlet UIView* square100x100;
@property (nonatomic,strong) IBOutlet UIView* square125x125;
@property (nonatomic,strong) IBOutlet UIView* square150x150;
@end
