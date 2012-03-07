//
//  LipiCharRecognizerResult.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LipiCharRecognizerResult.h"

@implementation LipiCharRecognizerResult
@synthesize recognizedChar;
@synthesize confidenceLevel;

- (id) initWithChar:(char)c confidence:(float)confidence {
    if ((self = [super init])) {
        self.recognizedChar = c;
        self.confidenceLevel = confidence;
    }
    return self;
}
@end