//
//  ViewController.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"

#include "LTKLoggerUtil.h"
#include "LTKErrors.h"
#include "LTKOSUtilFactory.h"
#include "LTKOSUtil.h"
#include "lipiengine.h"
#include "NNShapeRecognizer.h"
#include "LTKTrace.h"

#import "FilesConfigurator.h"
#import "GTVTransparentTouchView.h"

#define ENG_ALPHANUMERIC "ENG_ALPHANUMERIC"
#define ENG_LOWER "ENG_LOWER"
#define ENG_UPPER "ENG_UPPER"

#define LOGICAL_PROJECT_NAME ENG_UPPER

@interface ViewController()<GTVTransparentTouchViewDelegate>
@property (nonatomic,strong) FilesConfigurator* filesConfigurator;
@property (nonatomic,strong) GTVTransparentTouchView* touchView;

- (void) initRecognizer;
@end

@implementation ViewController
@synthesize filesConfigurator;
@synthesize touchView;
@synthesize shapeLabel;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRecognizer];
    self.touchView = [[GTVTransparentTouchView alloc] initWithFrame:self.view.bounds];
    self.touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.touchView.delegate = self;
    [self.view addSubview:self.touchView];
}

LTKOSUtil* utilPtr = LTKOSUtilFactory::getInstance();
LTKShapeRecognizer *pShapeReco = NULL;
LTKLipiEngineInterface *ptrObj = NULL;
LTKScreenContext screenContext;

- (void) initRecognizer {
    self.filesConfigurator = [[FilesConfigurator alloc] init];
    //create an instance of LipiEngine Module
    ptrObj = createLTKLipiEngine();
    const char* rootPath = [self.filesConfigurator.rootDir cStringUsingEncoding:NSUTF8StringEncoding];
	ptrObj->setLipiRootPath(rootPath);
    
	//Initialize the LipiEngine module
	int iResult = ptrObj->initializeLipiEngine();
	if(iResult != SUCCESS) {
		cout << iResult <<": Error initializing LipiEngine." << endl;
        delete utilPtr;
		return;
	}
	//Assign the logical name of the project to this string, i.e. TAMIL_CHAR 
	//(or) "HINDI_GESTURES"
	string strLogicalProjectName = string(LOGICAL_PROJECT_NAME);
    string strProjectName = "";
    string strProfileName = "";
    
	// Resolve the logical name into project name and profile name
	ptrObj->resolveLogicalNameToProjectProfile(strLogicalProjectName,
                                               strProjectName,
                                               strProfileName);
    
    int iMajor, iMinor, iBugfix;
    
    getToolkitVersion(iMajor, iMinor, iBugfix);
    char currentVersion[VERSION_STR_LEN];
	sprintf(currentVersion, "%d.%d.%d", iMajor, iMinor, iBugfix);
    
    LTKControlInfo controlInfo;
    controlInfo.lipiRoot = rootPath;
    controlInfo.projectName = strProjectName;
    controlInfo.profileName = strProfileName;
    controlInfo.toolkitVersion = currentVersion;
    
    pShapeReco = new NNShapeRecognizer(controlInfo);
	if(pShapeReco == NULL)
	{
		cout << endl << "Error creating Shape Recognizer" << endl;
        delete utilPtr;
        return;
	}
    
	iResult = pShapeReco->loadModelData();
	if(iResult != SUCCESS)
	{
		cout << endl << iResult << ": Error loading Model data." << endl;
		ptrObj->deleteShapeRecognizer(pShapeReco);
        delete utilPtr;
		return;
	}
    
	//Declare variables to be used for recognition...
	LTKCaptureDevice captureDevice;
    captureDevice.setSamplingRate(10);
	captureDevice.setXDPI(132);
	captureDevice.setYDPI(132);
	captureDevice.setLatency(10);
	captureDevice.setUniformSampling(true);
    
	//	Set the device context, once before starting the recognition...
	pShapeReco->setDeviceContext(captureDevice);
}

- (void) destroyRecognizer {
    if (NULL!=ptrObj) {
        ptrObj->deleteShapeRecognizer(pShapeReco);
        delete ptrObj;
    }
    if (NULL!=utilPtr) {
        delete utilPtr;
    }
}

- (void) initScreenContext {
    screenContext.setBboxTop(0);
    screenContext.setBboxBottom(self.view.bounds.size.height);
    screenContext.setBboxLeft(0);
    screenContext.setBboxRight(self.view.bounds.size.width);
    for (float x=0;x<self.view.bounds.size.width;x++) {
        screenContext.addVLine(x);
    }
    for (float y=0;y<self.view.bounds.size.height;y++) {
        screenContext.addHLine(y);
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self initScreenContext];
}

- (void) refreshRecognizedShapeId:(int)shapeId {
    char c;
    const int smallLetterBound = ((int)'z'-(int)'a');
    if (0==strcmp(ENG_ALPHANUMERIC, LOGICAL_PROJECT_NAME)) {
        int digitsBound = smallLetterBound+10;
        if (shapeId<=smallLetterBound) {
            c = 'a'+shapeId;
        } else if (shapeId<=digitsBound) {
            c = '0'+shapeId-smallLetterBound-1;
        } else {
            c = 'A'+shapeId-digitsBound-1;
        }
    } else if (0==strcmp(ENG_LOWER,LOGICAL_PROJECT_NAME)) {
        c = 'a'+shapeId;
    } else if (0==strcmp(ENG_UPPER, LOGICAL_PROJECT_NAME)) {
        c = 'A'+shapeId;
    }
    self.shapeLabel.text = [NSString stringWithFormat:@"%c",c];
}

- (void) recognizePointGroups:(NSArray *)pointGroups {
    [self.activityIndicator startAnimating];
    GCD_BKG_BLOCK
        vector<int> shapeSubset; 
        int numChoices = 2;
        float confThreshold = 0.0f;
        vector<LTKShapeRecoResult> results;
        LTKTraceGroup inTraceGroup;

        for (NSArray* points in pointGroups) {
            LTKTrace trace;        
            for (NSValue* val in points) {
                CGPoint pt = [val CGPointValue];
                vector<float> coord;
                coord.push_back(pt.x);
                coord.push_back(pt.y);
                trace.addPoint(coord);
            }
            inTraceGroup.addTrace(trace);
        }

        results.reserve(numChoices);

        int iResult = pShapeReco->recognize(inTraceGroup, screenContext, shapeSubset, confThreshold, numChoices, results);
        GCD_MAIN_BLOCK
            if (SUCCESS ==iResult) {
                float maxConfidence = 0;
                int maxConfidenceIndex = 0;
                for (int i=0;i<results.size();i++) {
                    float confidence = results.at(i).getConfidence();
                    if (confidence>maxConfidence) {
                        maxConfidence = confidence;
                        maxConfidenceIndex = i;
                    }
                }
                [self refreshRecognizedShapeId:results.at(maxConfidenceIndex).getShapeId()];
            }
            [self.activityIndicator stopAnimating];
        GCD_END_BLOCK
    GCD_END_BLOCK
}

- (void) viewDidUnload {
    [self destroyRecognizer];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    [self recognizePointGroups:pointGroups];
    return YES;
}
@end
