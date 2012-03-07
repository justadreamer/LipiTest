//
//  ViewController.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "LipiCharRecognizer.h"
#import "GTVTransparentTouchView.h"
#import "LipiCharRecognizerResult.h"
#define LOGICAL_PROJECT_NAME ENG_UPPER

@interface ViewController()<GTVTransparentTouchViewDelegate, LipiCharRecognizerDelegate>

@property (nonatomic,strong) LipiCharRecognizer* charRecognizerUpper;
@property (nonatomic,strong) LipiCharRecognizer* charRecognizerLower;
@property (nonatomic,assign) int startedRecognizers;
@property (nonatomic,strong) NSMutableArray* touchViews;
- (void) initRecognizers;
- (void) initTouchViews;

- (void) recognizerStarted;
- (void) recognizerFinished;
- (BOOL) allRecognizersFinished;
@end

@implementation ViewController
@synthesize charRecognizerUpper;
@synthesize charRecognizerLower;
@synthesize startedRecognizers;
@synthesize touchViews;

@synthesize shapeLabel1;
@synthesize shapeLabel2;
@synthesize activityIndicator;
@synthesize square50x50;
@synthesize square75x75;
@synthesize square100x100;
@synthesize square125x125;
@synthesize square150x150;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initRecognizers];
    [self initTouchViews];
    self.shapeLabel1.numberOfLines = 0;
    self.shapeLabel2.numberOfLines = 0;
}

#define ADD_TOUCH_VIEW(s) UIView* v##s = [[GTVTransparentTouchView alloc] initWithFrame:self.square##s##x##s.frame]; \
[self.touchViews addObject:v##s]; \
v##s.tag = s;

- (void) initTouchViews {
    self.touchViews = [NSMutableArray array];
    ADD_TOUCH_VIEW(50)
    ADD_TOUCH_VIEW(75)
    ADD_TOUCH_VIEW(100)
    ADD_TOUCH_VIEW(125)
    ADD_TOUCH_VIEW(150)
    for (GTVTransparentTouchView* touchView in self.touchViews) {
        touchView.delegate = self;
        UILabel* label = [[UILabel alloc] initWithFrame:touchView.frame];
        label.text = [NSString stringWithFormat:@"%dx%d",touchView.tag,touchView.tag];
        [self.view addSubview:label];
        [self.view addSubview:touchView];
    }
}

- (void) initRecognizers {
    self.charRecognizerUpper = [[LipiCharRecognizer alloc] initWithRecognizerType:LIPI_ENG_UPPER];
    self.charRecognizerUpper.delegate = self;
    
    self.charRecognizerLower = [[LipiCharRecognizer alloc] initWithRecognizerType:LIPI_ENG_LOWER];
    self.charRecognizerLower.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark GTVTouchViewDelegate

- (void) touchView:(GTVTransparentTouchView *)touchView pointGroupsDidChange:(NSArray *)pointGroups {
    
}

- (BOOL) touchView:(GTVTransparentTouchView *)touchView shouldTimerResetPointGroups:(NSArray *)pointGroups {
    self.charRecognizerUpper.bounds = touchView.bounds;
    [self.charRecognizerUpper recognizePointGroups:pointGroups];
    self.charRecognizerLower.bounds = touchView.bounds;
    [self.charRecognizerLower recognizePointGroups:pointGroups];
    return YES;
}

- (void) touchViewDidResetPointGroups:(GTVTransparentTouchView *)touchView {
    
}

#pragma mark -
#pragma mark LipiCharRecognizer

- (void) lipiCharRecognizerDidStart:(LipiCharRecognizer *)recognizer {
    [self recognizerStarted];
    [self.activityIndicator startAnimating];
}

- (void) lipiCharRecognizer:(LipiCharRecognizer*)recognizer didRecognize:(NSArray *)results {
    NSString* text = @"";
    for (LipiCharRecognizerResult* result in results) {
        text = [text stringByAppendingFormat:@"%c %.2f\n",result.recognizedChar, result.confidenceLevel];
    }

    UILabel* label = self.shapeLabel1;
    if (self.charRecognizerUpper == recognizer) {
        label = self.shapeLabel2;
    }
    label.text = text;
}

- (void) lipiCharRecognizerDidFinish:(LipiCharRecognizer *)recognizer {
    [self recognizerFinished];
    if ([self allRecognizersFinished]) {
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - 
#pragma mark recognizers management
- (void) recognizerStarted {
    self.startedRecognizers++;
}

- (void) recognizerFinished {
    self.startedRecognizers--;
}

- (BOOL) allRecognizersFinished {
    return self.startedRecognizers <= 0;
}
@end