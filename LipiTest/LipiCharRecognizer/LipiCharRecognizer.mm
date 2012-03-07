//
//  LipiCharRecognizer.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LipiCharRecognizer.h"
#import "LipiFilesConfigurator.h"
#import "LipiCharRecognizerResult.h"

#include "LTKLoggerUtil.h"
#include "LTKErrors.h"
#include "LTKOSUtilFactory.h"
#include "LTKOSUtil.h"
#include "lipiengine.h"
#include "NNShapeRecognizer.h"
#include "LTKTrace.h"

#define ENG_ALPHANUMERIC "ENG_ALPHANUMERIC"
#define ENG_LOWER "ENG_LOWER"
#define ENG_UPPER "ENG_UPPER"

@interface LipiCharRecognizer()
@property (nonatomic,retain) LipiFilesConfigurator* filesConfigurator;
@property (nonatomic,assign) LTKOSUtil* utilPtr;
@property (nonatomic,assign) LTKShapeRecognizer* pShapeReco;
@property (nonatomic,assign) LTKLipiEngineInterface* ptrObj;
@property (nonatomic,assign) LTKScreenContext screenContext;
@property (nonatomic,readonly,assign) string logicalProjectName;

- (void) initRecognizer;
- (void) initScreenContext;
@end

@implementation LipiCharRecognizer
@synthesize recognizerType;
@synthesize filesConfigurator;
@synthesize utilPtr;
@synthesize pShapeReco;
@synthesize ptrObj;
@synthesize screenContext;
@synthesize logicalProjectName;
@synthesize bounds;
@synthesize delegate;

#define SAFE_DELETE_C_PTR(ptr) { if (NULL!=ptr) {delete ptr; ptr = NULL;} }

- (void) destroyRecognizer {
    if (NULL!=self.ptrObj) {
        if (NULL !=self.pShapeReco) {
            self.ptrObj->deleteShapeRecognizer(self.pShapeReco);
            self.pShapeReco = NULL;
        }
        SAFE_DELETE_C_PTR(self.ptrObj);
    }
    SAFE_DELETE_C_PTR(utilPtr);
}

- (void) dealloc {
    self.delegate = nil;
    [self destroyRecognizer];
    self.filesConfigurator = nil;
    [super dealloc];
}

- (id) init {
    if ((self = [super init])) {
        self.filesConfigurator = [[[LipiFilesConfigurator alloc] init] autorelease];
        [self.filesConfigurator setupPaths];

        self.recognizerType = LIPI_ENG_UPPER;
        self.bounds = CGRectNull;
    }
    return self;
}

- (id) initWithRecognizerType:(LipiCharRecognizerType)type {
    if ((self = [self init])) {
        self.recognizerType = type;
        [self initRecognizer];
    }
    return self;
}

- (void) setBounds:(CGRect)_bounds {
    bounds = _bounds;
    [self initScreenContext];
}

- (string) logicalProjectName {
    string projectName = ENG_UPPER;
    if (LIPI_ENG_LOWER==self.recognizerType) {
        projectName = ENG_LOWER;
    } else if (LIPI_ENG_ALPHANUMERIC == self.recognizerType) {
        projectName = ENG_ALPHANUMERIC;
    }
    return projectName;
}

- (void) initRecognizer {
    self.utilPtr = LTKOSUtilFactory::getInstance();
    self.pShapeReco = NULL;
    self.ptrObj = NULL;

    self.filesConfigurator = [[LipiFilesConfigurator alloc] init];
    //create an instance of LipiEngine Module
    self.ptrObj = createLTKLipiEngine();
    const char* rootPath = [self.filesConfigurator.rootDir cStringUsingEncoding:NSUTF8StringEncoding];
	self.ptrObj->setLipiRootPath(rootPath);
    
	//Initialize the LipiEngine module
	int iResult = self.ptrObj->initializeLipiEngine();
	if(iResult != SUCCESS) {
		cout << iResult <<": Error initializing LipiEngine." << endl;
        delete self.utilPtr;
		return;
	}
	//Assign the logical name of the project to this string, i.e. TAMIL_CHAR 
	//(or) "HINDI_GESTURES"
	string strLogicalProjectName = self.logicalProjectName;
    string strProjectName = "";
    string strProfileName = "";
    
	// Resolve the logical name into project name and profile name
	self.ptrObj->resolveLogicalNameToProjectProfile(strLogicalProjectName,
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
    
    self.pShapeReco = new NNShapeRecognizer(controlInfo);
	if(self.pShapeReco == NULL)
	{
		cout << endl << "Error creating Shape Recognizer" << endl;
        delete utilPtr;
        return;
	}
    
	iResult = self.pShapeReco->loadModelData();
	if(iResult != SUCCESS)
	{
		cout << endl << iResult << ": Error loading Model data." << endl;
		self.ptrObj->deleteShapeRecognizer(self.pShapeReco);
        delete self.utilPtr;
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
	self.pShapeReco->setDeviceContext(captureDevice);
}

- (void) initScreenContext {
    self.screenContext.setBboxTop(0);
    self.screenContext.setBboxBottom(self.bounds.size.height);
    self.screenContext.setBboxLeft(0);
    self.screenContext.setBboxRight(self.bounds.size.width);
    for (float x=0;x<self.bounds.size.width;x++) {
        self.screenContext.addVLine(x);
    }
    for (float y=0;y<self.bounds.size.height;y++) {
        self.screenContext.addHLine(y);
    }
}

- (char) charForShapeId:(int)shapeId {
    char c;
    const int smallLetterBound = ((int)'z'-(int)'a');
    if (LIPI_ENG_ALPHANUMERIC == self.recognizerType) {
        int digitsBound = smallLetterBound+10;
        if (shapeId<=smallLetterBound) {
            c = 'a'+shapeId;
        } else if (shapeId<=digitsBound) {
            c = '0'+shapeId-smallLetterBound-1;
        } else {
            c = 'A'+shapeId-digitsBound-1;
        }
    } else if (LIPI_ENG_LOWER == self.recognizerType) {
        c = 'a'+shapeId;
    } else if (LIPI_ENG_UPPER == self.recognizerType) {
        c = 'A'+shapeId;
    }
    return c;
}

- (void) recognizePointGroups:(NSArray *)pointGroups {
    [self.delegate lipiCharRecognizerDidStart:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
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
        NSMutableArray* recognizedChars = [NSMutableArray array];
        if (SUCCESS ==iResult) {
            for (int i=0;i<results.size();i++) {
                int shapeId = results.at(i).getShapeId();
                float confidence = results.at(i).getConfidence();
                LipiCharRecognizerResult* result = [[LipiCharRecognizerResult alloc] initWithChar:[self charForShapeId:shapeId] confidence:confidence];
                [recognizedChars addObject:result];
            }
        }
        [recognizedChars sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"confidenceLevel" ascending:NO]]];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.delegate lipiCharRecognizer:self didRecognize:recognizedChars];
            [self.delegate lipiCharRecognizerDidFinish:self];
        });
    });
}

@end