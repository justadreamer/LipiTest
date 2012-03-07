//
//  GTVTransparentTouchViewDelegate.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GTVTransparentTouchView;

@protocol GTVTransparentTouchViewDelegate
- (void) touchView:(GTVTransparentTouchView*)touchView pointGroupsDidChange:(NSArray*)pointGroups;
- (BOOL) touchView:(GTVTransparentTouchView*)touchView shouldTimerResetPointGroups:(NSArray*)pointGroups;
- (void) touchViewDidResetPointGroups:(GTVTransparentTouchView*)touchView;
@end