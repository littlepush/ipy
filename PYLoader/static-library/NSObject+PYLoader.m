//
//  NSObject+PYLoader.m
//  PYLoader
//
//  Created by Push Chen on 10/12/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
//

#import "NSObject+PYLoader.h"

@implementation NSObject (PYLoader)

+ (id)objectWithOption:(NSDictionary *)option
{
    __TRY
    NSString *_objectClass = [option stringObjectForKey:@"type"];
    Class _class = NSClassFromString(_objectClass);
    if ( _class == NULL ) return nil;
    NSDictionary *_loadFunctionInfo = [option objectForKey:@"loader"];
    id _object = nil;
    if ( _loadFunctionInfo == nil ) {
        _object = [_class object];
    } else {
        _object = [_class alloc];
        
    }
    return _object;
    __CATCH(e)
    return nil;
    __END
}

@end
