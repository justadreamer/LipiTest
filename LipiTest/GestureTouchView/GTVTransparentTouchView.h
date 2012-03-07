//
//  TransparentTouchView.h
//  LifelikeClassifieds
//
//  Created by Eugene Dorfman on 4/15/11.
//  Copyright 2011 Postindustria. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTVTransparentTouchView;
#import "GTVTransparentTouchViewDelegate.h"

@interface GTVTransparentTouchView : UIView {
    
}
@property (nonatomic,retain) UIColor* strokeColor;
@property (nonatomic,assign) NSTimeInterval resetTimeInterval;
@property (nonatomic,retain) id<GTVTransparentTouchViewDelegate> delegate;
@end
