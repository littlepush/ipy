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

CGFloat const       PYScrollDecelerateDuration          = 2.5f;
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
- (void)setScrollSide:(PYScrollDirection)scrollSide
{
    _scrllSide = scrollSide;
    [self setEvent:PYResponderEventPan withRestraint:(PYResponderRestraint)scrollSide];
}
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

- (void)setContentSize:(CGSize)contentSize
{
    [self setContentSize:contentSize animated:NO];
}

// Dynamic properities setter.
- (void)setContentSize:(CGSize)contentSize animated:(BOOL)animated
{
    _contentSize = contentSize;
    
    for ( int i = 0; i < 2; ++i ) {
        int _rate = _SIDE(_contentOffset) / _SIDE(contentSize);
        CGFloat _max = _SIDE(contentSize) * _rate;
        _SIDE(_contentOffset) -= _max;
    }
    
    CGSize _appendSize = contentSize;
    if ( (_scrllSide & PYScrollHorizontal) > 0 ) {
        _appendSize.height = 0;
    } else {
        _appendSize.width = 0;
    }
    
    _coverFrame = CGRectZero;
    for ( int i = 0; i < [_subContentList count]; ++i ) {
        UIView *_sc = [_subContentList safeObjectAtIndex:i];
        CGRect _sf = CGRectMake(i * _appendSize.width,
                                i * _appendSize.height,
                                contentSize.width,
                                contentSize.height);
        [_sc setFrame:_sf];
        _coverFrame = PYRectCombine(_coverFrame, _sf);
    }
    _coverFrame.origin.x -= _contentOffset.width;
    _coverFrame.origin.y -= _contentOffset.height;
    
    // Animate to move the view.
    if ( animated ) {
        [UIView beginAnimations:@"ContentSize" context:nil];
        [UIView setAnimationDuration:.175];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    for ( UIView *_sc in _subContentList ) {
#ifdef _SCROLL_USE_LAYER_TRANSFORM_
        _sc.layer.transform = CATransform3DMakeTranslation(-_contentOffset.width,
                                                           -_contentOffset.height,
                                                           0);
#else
        _sc.transform = CGAffineTransformMakeTranslation(-_contentOffset.width,
                                                         -_contentOffset.height);
#endif
    }
    if ( animated ) {
        [UIView commitAnimations];
    }
}

- (void)setContentOffset:(CGSize)contentOffset
{
    [self setContentOffset:contentOffset animated:NO];
}

- (void)setContentOffset:(CGSize)contentOffset animated:(BOOL)animated
{
    if ( _contentSize.width * _contentSize.height == 0 ) return;
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
    NSMutableArray *_subs = [NSMutableArray array];
    for ( UIView *_ctntView in _subContentList ) {
        [_subs addObjectsFromArray:_ctntView.subviews];
    }
    return _subs;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    for ( UIView *_ctntView in _subContentList ) {
        [_ctntView setBackgroundColor:backgroundColor];
    }
}

- (void)setClipsToBounds:(BOOL)clipsToBounds
{
    [super setClipsToBounds:clipsToBounds];
    for ( UIView *_ctntView in _subContentList ) {
        [_ctntView setClipsToBounds:clipsToBounds];
    }
}

- (void)_actionTouchBeginHandler:(id)sender event:(PYViewEvent *)event
{
    @synchronized ( self ) {
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
    _coverFrame = CGRectZero;
    _contentSize = CGSizeZero;
    _contentOffset = CGSizeZero;
    _contentInsets = UIEdgeInsetsZero;
    _willStopOffset = CGSizeZero;
    _contentRect = CGRectZero;
    _pageSize = CGSizeZero;
    _pagable = NO;
    _loopSupported = NO;
    _bounceStatus[0] = _bounceStatus[1] = YES;
    _subContentList = [NSMutableArray array];
    
    _contentView = (UIView *)[[[self class] contentViewClass] object];
    PYASSERT([_contentView isKindOfClass:[UIView class]],
             @"The content view class must be a subclass of UIView");
    [_subContentList addObject:_contentView];
    [self addSubview:_contentView];

    [self setClipsToBounds:YES];
    
    [self setEvent:PYResponderEventPan withRestraint:PYResponderRestraintPanFreedom];
    [self addTarget:self
             action:@selector(_actionTouchBeginHandler:event:)
  forResponderEvent:PYResponderEventTouchBegin];
    [self addTarget:self
             action:@selector(_actionTouchEndHandler:event:)
  forResponderEvent:PYResponderEventTouchEnd];
    [self addTarget:self
             action:@selector(_actionTouchPenHandler:event:)
  forResponderEvent:PYResponderEventPan];
}

- (void)scrollToTop
{
    if ( _loopSupported == YES ) return;
    [self setContentOffset:CGSizeMake(_contentOffset.width, 0) animated:YES];
}
- (void)scrollToLeft
{
    if ( _loopSupported == YES ) return;
    [self setContentOffset:CGSizeMake(0, _contentOffset.height) animated:YES];
}
- (void)scrollToBottom
{
    if ( _loopSupported == YES ) return;
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
    if ( _loopSupported == YES ) return;
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

- (void)scrollToNextPage:(BOOL)animated
{
    @synchronized( self ) {
        if ( _pagable == NO ) return;
        // Last decelerate hasn't stopped
        if ( _decelerateTimer != nil ) return;
        CGSize _ctntOffset = _contentOffset;
        CGFloat _value = _SIDE_ITEM(_ctntOffset);
        int _t = ((_value + PYINDICATION_F(1.f, _value)) / _SIDE_ITEM(_pageSize));
        _value = _SIDE_ITEM(_pageSize) * (_t + 1);
        _SIDE_ITEM(_ctntOffset) = _value;
        _VSIDE_ITEM(_ctntOffset) = 0.f;
        [self setContentOffset:_ctntOffset animated:animated];
    }
}
- (void)scrollToPreviousPage:(BOOL)animated
{
    @synchronized( self ) {
        if ( _pagable == NO ) return;
        // Last decelerate hasn't stopped
        if ( _decelerateTimer != nil ) return;
        CGSize _ctntOffset = _contentOffset;
        CGFloat _value = _SIDE_ITEM(_ctntOffset);
        int _t = ((_value + PYINDICATION_F(1.f, _value)) / _SIDE_ITEM(_pageSize));
        _value = _SIDE_ITEM(_pageSize) * (_t - 1);
        _SIDE_ITEM(_ctntOffset) = _value;
        _VSIDE_ITEM(_ctntOffset) = 0.f;
        [self setContentOffset:_ctntOffset animated:animated];
    }
}

- (void)addSubview:(UIView *)view
{
    if ( [_subContentList containsObject:view] ) {
        [super addSubview:view];
    } else {
        [_contentView addSubview:view];
    }
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    if ( [_subContentList containsObject:view] ) {
        [super insertSubview:view aboveSubview:siblingSubview];
    } else {
        [_contentView insertSubview:view aboveSubview:siblingSubview];
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    if ( [_subContentList containsObject:view] ) {
        [super insertSubview:view atIndex:index];
    } else {
        [_contentView insertSubview:view atIndex:index];
    }
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    if ( [_subContentList containsObject:view] ) {
        [super insertSubview:view belowSubview:siblingSubview];
    } else {
        [_contentView insertSubview:view belowSubview:siblingSubview];
    }
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
