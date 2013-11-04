//
//  NSObject+PYLoader.h
//  PYLoader
//
//  Created by Push Chen on 10/12/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PYPRINTEXP(e)       \
    PYLog(@"\n%@\n%@", e.reason, e.callStackSymbols)
#define __TRY       @try {
#define __CATCH(e)  } @catch( NSException *e ) { PYPRINTEXP(e);
#define __FINAL     } @finally {
#define __END       }

@interface NSObject (PYLoader)

+ (id)objectWithOption:(NSDictionary *)option;

@end
