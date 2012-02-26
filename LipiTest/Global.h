//
//  Global.h
//  LipiTest
//
//  Created by Eugene Dorfman on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef LipiTest_Global_h
#define LipiTest_Global_h

#import "DLog.h"

#define GCD_BKG_BLOCK dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
#define GCD_MAIN_BLOCK dispatch_async(dispatch_get_main_queue(), ^ {
#define GCD_END_BLOCK });

#endif
