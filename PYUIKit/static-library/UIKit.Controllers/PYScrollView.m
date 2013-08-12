//
//  PYScrollView.m
//  PYUIKit
//
//  Created by Push Chen on 7/30/13.
//  Copyright (c) 2013 Push Lab. All rights reserved.
//

/*
 LISENCE FOR IPY
 COPYRIGHT (c) 2013, Push Chen.
 ALL RIGHTS RESERVED.
 
 REDISTRIBUTION AND USE IN SOURCE AND BINARY
 FORMS, WITH OR WITHOUT MODIFICATION, ARE
 PERMITTED PROVIDED THAT THE FOLLOWING CONDITIONS
 ARE MET:
 
 YOU USE IT, AND YOU JUST USE IT!.
 WHY NOT USE THIS LIBRARY IN YOUR CODE TO MAKE
 THE DEVELOPMENT HAPPIER!
 ENJOY YOUR LIFE AND BE FAR AWAY FROM BUGS.
 */

#import "PYScrollView.h"
#import "PYScrollView+SideAnimation.h"

CGFloat const       PYScrollDecelerateDuration          = 3.f;
CGFloat const       PYScrollDecelerateDurationPiece     = .01f;
CGFloat const       PYScrollDecelerateNeedBounceDuration= .15f;
CGFloat const       PYScrollBounceBackDuration          = .2f;
NSUInteger const    PYScrollDecelerateTimePiece         = (int)(PYScrollDecelerateDuration /
                                                                PYScrollDecelerateDurationPiece);
CGFloat const       PYScrollDirectOffsetDuration        = .175;
NSUInteger const    PYScrollDirectOffsetTimePiece       = (int)(PYScrollDirectOffsetDuration /
                                                                PYScrollDecelerateDurationPiece);
CGFloat const       PYScrollDecelerateStepRate          = .95f;
CGFloat const       PYScrollOverheadRate                = .45;

@implementation PYScrollView

+ (Class)contentViewClass
{
    return [UIView class];
}

@synthesize scrollSide = _scrllSide;
@synthesize decelerateSpeed = _decelerateSpeed;
@dynamic alwaysBounceHorizontal;
- (BOOL)alwaysBounceHorizontal
{
    return _bounceStatus[0];
}
- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal
{
    _bounceStatus[0] = alwaysBounceHorizontal;
}
@dynamic alwaysBounceVertical;
- (BOOL)alwaysBounceVertical
{
    return _bounceStatus[1];
}
- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical
{
    _bounceStatus[1] = alwaysBounceVertical;
}
@synthesize pageSize = _pageSize;
@synthesize isPagable = _pagable;
- (void)setPagable:(BOOL)pagable
{
    _pagable = pagable;
}

// Dynamic properities setter.
- (void)setContentSize:(CGSize)contentSize
{
    _contentSize = contentSize;
    CGRect _ctntFrame = _contentView.frame;
    _ctntFrame.size = contentSize;
    [_contentView setFrame:_ctntFrame];
}

- (void)setContentOffset:(CGSize)contentOffset
{
    [self setContentOffset:contentOffset animated:NO];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    CGRect _ctntFrame = _contentView.frame;
    _ctntFrame.origin.x -= _contentInsets.left;
    _ctntFrame.origin.y -= _contentInsets.top;
    _contentInsets = contentInsets;
    _ctntFrame.origin.x += _contentInsets.left;
    _ctntFrame.origin.y += _contentInsets.top;
    [_contentView setFrame:_ctntFrame];
}

// Override super properties
- (NSArray *)subviews
{
    return [_contentView subviews];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [_contentView setBackgroundColor:backgroundColor];
}

- (void)setClipsToBounds:(BOOL)clipsToBounds
{
    [super setClipsToBounds:clipsToBounds];
    [_contentView setClipsToBounds:clipsToBounds];
}

- (void)_actionTouchBeginHandler:(id)sender event:(PYViewEvent *)event
{
    // Tell the delegate
    if ( _decelerateTimer != nil ) {
        [_decelerateTimer invalidate];
        _decelerateTimer = nil;
    }
    if ( _contentSize.width * _contentSize.height == 0 ) return;
    [((NSObject *)self.delegate)
     tryPerformSelector:@selector(pyScrollViewWillBeginToScroll:)
     withObject:self];
}

- (void)_actionTouchEndHandler:(id)sender event:(PYViewEvent *)event
{
    if ( _contentSize.width * _contentSize.height == 0 ) return;
    if ( event.hasMoved == NO ) return;
    BOOL _willDecelerate = YES;
    if ( event.movingSpeed.x == 0 && event.movingSpeed.y == 0 ) {
        _willDecelerate = NO;
    }
    if ( _decelerateSpeed == PYDecelerateSpeedZero ) {
        _willDecelerate = NO;
    }
    
    // Calculate the decelerate distance
    if ( _willDecelerate == YES ) {
        CGFloat _decelerateRate = _decelerateSpeed * 2.5f;
        CGSize _initDecelerateSpeed = CGSizeMake(event.movingSpeed.x * _decelerateRate,
                                                 event.movingSpeed.y * _decelerateRate);
        if ( (_scrllSide & PYScrollHorizontal) == 0 ) _initDecelerateSpeed.width = 0;
        if ( (_scrllSide & PYScrollVerticalis) == 0 ) _initDecelerateSpeed.height = 0;
        
        // Calculate the decelerate distance.
        [self calculateDecelerateDistanceAndSetJellyPointWithInitSpeed:_initDecelerateSpeed
                                                    decelerateDuration:&_decelerateDuration
                                                        bounceDuration:&_bounceDuration];
        // Ask if we should continue with these setting.
        _willDecelerate = [self willScrollWithMovingDistance:_willStopOffset];
    }
    
    // Tell the delegate.
    if ( [self.delegate respondsToSelector:@selector(pyScrollViewDidEndScroll:willDecelerate:)] ) {
        [self.delegate pyScrollViewDidEndScroll:self willDecelerate:_willDecelerate];
    }
    
    // Return if not need to decelerate
    if ( _willDecelerate == NO ) return;
    
    [self animatedScrollWithOffsetDistance:_willStopOffset
                          withinTimePieces:_SCROLL_TIME_PIECE_(_decelerateDuration)];
}

- (void)_actionTouchPenHandler:(id)sender event:(PYViewEvent *)event
{
    if ( _contentSize.width * _contentSize.height == 0 ) return;
    // Move the subviews
    CGSize _movingDistance = event.movingDeltaDistance;
    if ( (_scrllSide & PYScrollHorizontal) == 0 ) _movingDistance.width = 0;
    if ( (_scrllSide & PYScrollVerticalis) == 0 ) _movingDistance.height = 0;

    [self setMovingOffset:_movingDistance withAnimatDuration:0];
}

- (void)viewJustBeenCreated
{
    [super viewJustBeenCreated];
    
    // Initialize the scroll side as freedom.
    // [self setClipsToBounds:YES];
    _scrllSide = PYScrollFreedom;
    _decelerateSpeed = PYDecelerateSpeedNormal;
    
    // Initialize the data
    _contentSize = CGSizeZero;
    _contentOffset = CGSizeZero;
    _contentInsets = UIEdgeInsetsZero;
    _willStopOffset = CGSizeZero;
    _contentRect = CGRectZero;
    _pageSize = CGSizeZero;
    _pagable = NO;
    _loopSupported = NO;
    _bounceStatus[0] = _bounceStatus[1] = YES;
    
    _contentView = (UIView *)[[[self class] contentViewClass] object];
    PYASSERT([_contentView isKindOfClass:[UIView class]],
             @"The content view class must be a subclass of UIView");
    [self addSubview:_contentView];

    [self setClipsToBounds:YES];
    
    [self setEvent:PYResponderEventPen withRestraint:PYResponderRestraintPenFreedom];
    [self addTarget:self
             action:@selector(_actionTouchBeginHandler:event:)
  forResponderEvent:PYResponderEventTouchBegin];
    [self addTarget:self
             action:@selector(_actionTouchEndHandler:event:)
  forResponderEvent:PYResponderEventTouchEnd];
    [self addTarget:self
             action:@selector(_actionTouchPenHandler:event:)
  forResponderEvent:PYResponderEventPen];
}

- (void)setContentOffset:(CGSize)contentOffset animated:(BOOL)animated
{
    CGSize _stopPoint = CGSizeMake(-contentOffset.width, -contentOffset.height);
    CGSize _currentPoint = CGSizeMake(-_contentOffset.width, -_contentOffset.height);
    CGSize _movingOffset = CGSizeMake(_stopPoint.width - _currentPoint.width,
                                      _stopPoint.height - _currentPoint.height);
    if ( animated ) {
        [self animatedScrollWithOffsetDistance:_movingOffset
                              withinTimePieces:PYScrollDirectOffsetTimePiece];
    } else {
        [self setMovingOffset:_movingOffset withAnimatDuration:0];
    }
}

- (void)scrollToTop
{
    [self setContentOffset:CGSizeMake(_contentOffset.width, 0) animated:YES];
}
- (void)scrollToLeft
{
    [self setContentOffset:CGSizeMake(0, _contentOffset.height) animated:YES];
}
- (void)scrollToBottom
{
    if ( _contentSize.height < self.bounds.size.height ) {
        [self scrollToTop];
    } else {
        [self
         setContentOffset:CGSizeMake(_contentOffset.width,
                                     _contentSize.height -
                                     self.bounds.size.height)
         animated:YES];
    }
}
- (void)scrollToRight
{
    if ( _contentSize.width < self.bounds.size.width ) {
        [self scrollToLeft];
    } else {
        [self
         setContentOffset:CGSizeMake(_contentSize.width -
                                     self.bounds.size.width,
                                     _contentOffset.height)
         animated:YES];
    }
}

- (void)addSubview:(UIView *)view
{
    if ( view == _contentView ) {
        [super addSubview:view];
    } else {
        [_contentView addSubview:view];
    }
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    [_contentView insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [_contentView insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    [_contentView insertSubview:view belowSubview:siblingSubview];
}

- (BOOL)willScrollWithMovingDistance:(CGSize)movingDistance
{
    // nothing to do in super class
    return YES;
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
