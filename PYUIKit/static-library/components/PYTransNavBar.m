//
//  PYTransNavBar.m
//  FootPath
//
//  Created by Push Chen on 1/19/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYTransNavBar.h"
#import "PYLibImage.h"

@implementation PYTransNavBar

- (id)initWithFrame:(CGRect)frame {
  	//frame.size.height = 60;
    self = (PYTransNavBar *)[super initWithFrame:frame];
    if (self) {
        // Initialization code.
		#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
		if ( [self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
			[self setBackgroundImage:[PYLibImage imageForKey:PYLibImageIndexNavbarTBkg]
				forBarMetrics:0];
		}
		#endif
		[self setBackgroundColor:[UIColor clearColor]];
    }
	//self.frame.size.height = 60;
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = (PYTransNavBar *)[super initWithCoder:aDecoder];
	if ( self ) {
		#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
		if ( [self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
			[self setBackgroundImage:[PYLibImage imageForKey:PYLibImageIndexNavbarTBkg]
				forBarMetrics:0];
		}
		#endif
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

-(id)init {
	self = (PYTransNavBar *)[super init];
	if ( self ) {
		#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
		if ( [self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
			[self setBackgroundImage:[PYLibImage imageForKey:PYLibImageIndexNavbarTBkg]
				forBarMetrics:0];
		}
		#endif
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
		UIImage *_transImage = [PYLibImage imageForKey:PYLibImageIndexNavbarTBkg];
		[_transImage drawInRect:self.bounds];
	}
}


- (void)dealloc {
    [super dealloc];
}

@end
