//
//  LipiCharRecognizerResult.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LipiCharRecognizerResult : NSObject
@property (nonatomic,assign) char recognizedChar;
@property (nonatomic,assign) float confidenceLevel;

- (id) initWithChar:(char)c confidence:(float)confidence;
@end