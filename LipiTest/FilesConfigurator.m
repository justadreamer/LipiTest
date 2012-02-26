//
//  FilesConfigurator.m
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Global.h"
#import "FilesConfigurator.h"

@implementation FilesConfigurator
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
    NSString* pathToProjects = [[NSBundle mainBundle] resourcePath];
    NSString* projectsComponent = @"projects";
    pathToProjects = [pathToProjects stringByAppendingPathComponent:projectsComponent];

    NSString* toPath = [self.rootDir stringByAppendingPathComponent:projectsComponent];
    NSError* deleteErr = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:toPath error:&deleteErr]) {
        VLog(deleteErr);
    }
    NSError* copyErr = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:pathToProjects toPath:toPath error:&copyErr]) {
        VLog(copyErr);
    }
}
@end
