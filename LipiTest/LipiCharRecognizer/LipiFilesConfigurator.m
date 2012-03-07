//
//  FilesConfigurator.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Global.h"
#import "LipiFilesConfigurator.h"

@implementation LipiFilesConfigurator
@synthesize rootDir;
- (id) init {
    if ((self = [super init])) {
        [self setupPaths];
    }
    return self;
}
- (NSString *)applicationSupportDirectory
{
	NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

	if (![[NSFileManager defaultManager] fileExistsAtPath:dir] ) {
        NSError* error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    }

	return dir;
}

- (void) setupPaths {
    self.rootDir = [self applicationSupportDirectory];
    NSString* projects = @"projects";
    NSString* fromPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:projects];
    NSString* toPath = [self.rootDir stringByAppendingPathComponent:projects];

    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        NSError* copyErr = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error:&copyErr]) {
            VLog(copyErr);
        }
    }
}

@end
