//
//  GTVGlobals.h
//  GestureTouchViewExample
//
//  Created by Eugene Dorfman on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GestureTouchViewExample_GTVGlobals_h
#define GestureTouchViewExample_GTVGlobals_h

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#define VLog(v) DLog(#v @"=%@",v)

#define CALL_FAILED(delegate) { DLog(@"Call failed: delegate=%@",delegate) }

#define SAFE_DELEGATE_CALL(delegate,sel) if (delegate && [delegate respondsToSelector:@selector(sel)]) { [delegate sel]; } else CALL_FAILED(delegate)
#define SAFE_DELEGATE_CALL1(delegate,sel,arg) if (delegate && [delegate respondsToSelector:@selector(sel:)]) { [delegate sel:arg]; } else CALL_FAILED(delegate)
#define SAFE_DELEGATE_CALL2(delegate,sel1,arg1,sel2,arg2) if (delegate && [delegate respondsToSelector:@selector(sel1:sel2:)]) { [delegate sel1:arg1 sel2:arg2]; } else CALL_FAILED(delegate)
#define SAFE_DELEGATE_CALL3(delegate,sel1,arg1,sel2,arg2,sel3,arg3) if (delegate && [delegate respondsToSelector:@selector(sel1:sel2:sel3:)]) { [delegate sel1:arg1 sel2:arg2 sel3:arg3]; } else CALL_FAILED(delegate)

#endif