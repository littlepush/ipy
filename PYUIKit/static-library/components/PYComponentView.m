//
//  PYComponentView.m
//  pyutility-uitest
//
//  Created by Push Chen on 6/5/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

@implementation PYComponentView

@synthesize IsInitialed = _initialed;

-(void) internalInitial
{
	_initialed = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self internalInitial];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self internalInitial];
	}
	return self;
}

- (id)init 
{
	self = [super init];
	if (self) {
		// Initialization code
		[self internalInitial];
	}
	return self;
}

-(void) layoutSubviews 
{
	PYComponentViewInitChecking
	[super layoutSubviews];
}

-(void) setNeedsLayout
{
	_initialed = NO;
	[super setNeedsLayout];	
}

-(void) setNeedsDisplayInRect:(CGRect)rect
{
	_initialed = NO;
	[super setNeedsDisplayInRect:rect];
}

-(void) setNeedsDisplay
{
	_initialed = NO;
	[super setNeedsDisplay];
}

-(void) setFrame:(CGRect)frame
{
	_initialed = NO;
	[super setFrame:frame];
}

@end

@implementation PYTouchView

@synthesize IsInitialed = _initialed;

-(void) internalInitial
{
	_initialed = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self internalInitial];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		// Initialization code
		[self internalInitial];
	}
	return self;
}

- (id)init 
{
	self = [super init];
	if (self) {
		// Initialization code
		[self internalInitial];
	}
	return self;
}

-(void) layoutSubviews 
{
	PYComponentViewInitChecking
	[super layoutSubviews];
}

-(void) setNeedsLayout
{
	_initialed = NO;
	[super setNeedsLayout];	
}

-(void) setNeedsDisplayInRect:(CGRect)rect
{
	_initialed = NO;
	[super setNeedsDisplayInRect:rect];
}

-(void) setNeedsDisplay
{
	_initialed = NO;
	[super setNeedsDisplay];
}

-(void) setFrame:(CGRect)frame
{
	_initialed = NO;
	[super setFrame:frame];
}

@end
