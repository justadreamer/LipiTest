//
//  LipiCharRecognizer.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    LIPI_ENG_UPPER,
    LIPI_ENG_LOWER,
    LIPI_ENG_ALPHANUMERIC
} LipiCharRecognizerType;

#import "LipiCharRecognizerDelegate.h"

@interface LipiCharRecognizer : NSObject
@property (nonatomic,assign) LipiCharRecognizerType recognizerType;
@property (nonatomic,assign) CGRect bounds;
@property (nonatomic,assign) NSObject<LipiCharRecognizerDelegate>* delegate;

- (void) recognizePointGroups:(NSArray *)pointGroups;

- (id) initWithRecognizerType:(LipiCharRecognizerType)type;
@end