//
//  FilesConfigurator.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LipiFilesConfigurator : NSObject
- (void) setupPaths;
@property (nonatomic,strong) NSString* rootDir;
@end