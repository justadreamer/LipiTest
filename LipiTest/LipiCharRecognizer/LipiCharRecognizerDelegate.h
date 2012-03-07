//
//  LipiCharRecognizerDelegate.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LipiCharRecognizer;

@protocol LipiCharRecognizerDelegate <NSObject>

- (void) lipiCharRecognizerDidStart:(LipiCharRecognizer*)recognizer;

- (void) lipiCharRecognizer:(LipiCharRecognizer*)recognizer didRecognize:(NSArray*)results;

- (void) lipiCharRecognizerDidFinish:(LipiCharRecognizer*)recognizer;
@end
