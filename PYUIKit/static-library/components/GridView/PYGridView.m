//
//  PYGridView.m
//  PYUIKit
//
//  Created by Push Chen on 5/15/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYGridView.h"
#import "PYGridViewCell.h"
#import "UIColor+PYUIKit.h"
#import "PYGridViewSection.h"
#import "PYGridViewCell+Parent.h"
#import "PYGridView+Internal.h"
#import "PYRect.h"

#define _TS(f)                                  ((f) * 1000)
//#define _GRID_SCROLL_ANIMATION_DURATION_        .04
#define _GRID_MOVE_EXPONENTIAL_                 .9
#define _GRID_SCROLL_ANIMATION_ALLTIME          2.f

@implementation PYGridView

- (void)dealloc
{
    if ( _animateScrollTimer != nil ) {
        [_animateScrollTimer invalidate];
        _animateScrollTimer = nil;
    }
}

// The decelerate speed, default is normal.
@synthesize decelerateSpeed;
- (PYGridViewDecelerateSpeed)decelerateSpeed
{
    return (PYGridViewDecelerateSpeed)(int)(_animateTimeSpace * 1000);
}
- (void)setDecelerateSpeed:(PYGridViewDecelerateSpeed)speed
{
    _animateTimeSpace = ((float)speed / 1000.f);
}

// Datasource and delegate, which provide the cell infomations and the receive the
// action occurred by the grid view.
@synthesize datasource, delegate;

@dynamic visiableCells;
- (NSArray *)visiableCells {
    NSMutableArray *_visiableCells = [NSMutableArray array];
    for ( PYGridViewSection *_section in _visiableSections ) {
        [_visiableCells addObjectsFromArray:_section.cellsInSection];
    }
    return _visiableCells;
}
@synthesize visiableRect;
- (CGRect)visiableRect
{
    return [self _currentVisiableSectionRect];
}

@dynamic contentOffset;
- (CGPoint)contentOffset
{
    CGRect _vr = CGRectZero;
    if ( [_visiableSections count] > 0 ) {
        _vr = [self _currentVisiableSectionRect];
    }
    int _currentTop = _topSection;
    int _topLimit = (_cycleEnabled == NO && _headSection != nil) ? -1 : 0;
    CGFloat _topLeftSpace = 0.f;
    while ( _currentTop > _topLimit ) {
        _topLeftSpace += [self _sectionRealtimeSizeAtIndex:(_currentTop -= 1)];
    }
    _ALONG_SIDE_ORIGIN(_vr) = -_ALONG_SIDE_ORIGIN(_vr);
    return _vr.origin;
}

@dynamic contentSize;
- (CGSize)contentSize
{
    CGSize _s = _maxSectionSize;
    BOOL _needHead = (_cycleEnabled == NO && _headSection != nil);
    if ( _needHead ) {
        CGRect _hr = _headSection.sectionFrame;
        _ALONG_SIDE_(_s.width) += _ALONG_SIDE_SIZE(_hr);
    }
    BOOL _needFoot = (_cycleEnabled == NO && _footSection != nil);
    if ( _needFoot ) {
        CGRect _fr = _footSection.sectionFrame;
        _ALONG_SIDE_(_s.width) += _ALONG_SIDE_SIZE(_fr);
    }
    return _s;
}

// All cell count
@synthesize numberOfCells = _numberOfCells;

//@synthesize headView = _headView;
@dynamic headView;
- (UIView *)headView
{
    if ( _headSection != nil ) {
        return _headSection.sectionView;
    }
    return nil;
}
- (void)setHeadView:(UIView *)hv
{
    [PYView animateWithDuration:.3 animations:^{
        if ( _headSection != nil ) {
            CGSize _headSize = [_headSection sectionFrame].size;
            
            if ( _cycleEnabled == NO ) {
                [_headSection removeSectionFromGridView];
                
                _STATIC_SIDE_(_headSize.width) = 0.f;
                _ALONG_SIDE_(_headSize.width) *= -1;
                [self _visiableSectionsMoveWithOffset:_headSize];
            }
            _headSection = nil;
        }
        
        if ( hv == nil ) return;
        
        _headSection = [[PYGridViewSection alloc]
                        initSectionWithGridView:self sectionIndex:-1
                        cellSizeCache:[NSArray array] headerView:hv];
        
        if ( _cycleEnabled == NO ) {
            CGSize _headSize = hv.frame.size;
            _STATIC_SIDE_(_headSize.width) = 0.f;
            [self _visiableSectionsMoveWithOffset:_headSize];
        }
    }];
}
@dynamic footView;
- (UIView *)footView
{
    if ( _footSection != nil ) {
        return _footSection.sectionView;
    }
    return nil;
}
- (void)setFootView:(UIView *)fv
{
    [PYView animateWithDuration:.3 animations:^{
        if ( _footSection != nil ) {
            CGSize _footSize = [_footSection sectionFrame].size;
            
            if ( _cycleEnabled == NO ) {
                [_footSection removeSectionFromGridView];
                
                _STATIC_SIDE_(_footSize.width) = 0.f;
                [self _visiableSectionsMoveWithOffset:_footSize];
            }
            _footSection = nil;
        }
        
        if ( fv == nil ) return;
        
        _footSection = [[PYGridViewSection alloc]
                        initSectionWithGridView:self sectionIndex:_sectionCount
                        cellSizeCache:[NSArray array] headerView:fv];        
    }];
}

// Enable cycle
@synthesize cycleEnabled = _cycleEnabled;
- (void)setCycleEnabled:(BOOL)cycled
{
    _cycleEnabled = cycled;
    [PYView animateWithDuration:.3 animations:^{
        if ( _cycleEnabled == YES ) {
            if ( _headSection != nil ) {
                CGSize _headSize = _headSection.sectionView.frame.size;
                //_ALONG_SIDE_(_headSize.width) += .1f;
                _ALONG_SIDE_(_headSize.width) *= -1;
                _STATIC_SIDE_(_headSize.width) = 0.f;
                [self _visiableSectionsMoveWithOffset:_headSize];
            }
        } else {
            if ( _headSection != nil ) {
                CGSize _headSize = _headSection.sectionView.frame.size;
                _STATIC_SIDE_(_headSize.width) = 0.f;
                [self _visiableSectionsMoveWithOffset:_headSize];
            }
        }
    }];
}
@dynamic isCycleEnabled;
- (BOOL)isCycleEnabled
{
    return _cycleEnabled;
}

// Enable page
@synthesize pageEnabled = _pageEnabled;
@dynamic isPageEnabled;
- (BOOL)isPageEnabled
{
    return _pageEnabled;
}

// Section type
@synthesize sectionType = _sectionType;
- (void)setSectionType:(PYGridViewSectionType)type
{
    _sectionType = type;
    for ( PYGridViewSection *_section in _visiableSections ) {
        [_section setSectionType:type];
    }
}

// Scroll Type, default is Vericial
@synthesize scrollType = _scrollType;

// Clear data
- (void)clearData
{
    if ( _animateScrollTimer != nil ) {
        [_animateScrollTimer invalidate];
        _animateScrollTimer = nil;
    }
    
    for ( PYGridViewSection * _section in _visiableSections ) {
        [_section removeSectionFromGridView];
    }
    [_visiableSections removeAllObjects];
    [_sectionCellHeightCacheList removeAllObjects];
    [_sectionCellsFrameCacheList removeAllObjects];
    [_sectionHeadViewCacheList removeAllObjects];
    [_sectionCollapseStatusList removeAllObjects];
    [_sectionHeadFrameCacheList removeAllObjects];
    [_cellSelectedStatus removeAllObjects];
    _lastSelectedItem = nil;
    _numberOfCells = 0;
    
    _bottomSection = -1;
    _topSection = 0;
    
    _canAnimateToNextOffset = NO;
    _maxSectionSize = CGSizeZero;
}
// Update current visiable area
// Any code between these two messages will be operated animated.
- (void)beginUpdate
{
    
}
- (void)endUpdate
{
}

// Reload all cells in grid view.
- (void)reloadData
{
    // Need to clear old data.
    [self clearData];
    
    _sectionCount = 1;
    if ( [self.datasource respondsToSelector:@selector(numberOfSectionInGridView:)] ) {
        _sectionCount = [self.datasource numberOfSectionInGridView:self];
    }
    
    for ( NSUInteger _s = 0; _s < _sectionCount; ++_s ) {
        NSUInteger _cellCount = [self _cellCountOfSection:_s];
        _numberOfCells += _cellCount;
        NSMutableArray *_cellHeightCache = [NSMutableArray array];
        
        // Load Section Head Information
        NSMutableSet *_headSet = [NSMutableSet set];
        CGSize _sectionSize = CGSizeZero;
        UIView *_sectionHeadView = [self _sectionViewAtIndex:_s];
        if ( _sectionHeadView != nil ) {
            [_headSet addObject:_sectionHeadView];
            CGRect _sectionBound = _sectionHeadView.bounds;
            _ALONG_SIDE_(_sectionSize.width) = _ALONG_SIDE_SIZE(_sectionBound);
        }
        [_sectionHeadFrameCacheList addObject:[NSValue valueWithCGSize:_sectionSize]];
        [_sectionHeadViewCacheList addObject:_headSet];
        
        // Load Cells infomation
        for ( NSUInteger i = 0; i < _cellCount; ++i ) {
            CGSize _sizeOfCell = [self _cellSizeAtIndexPath:
                                  [NSIndexPath indexPathForRow:i inSection:_s]];
            [_cellHeightCache addObject:[NSValue valueWithCGSize:_sizeOfCell]];
            _ALONG_SIDE_(_sectionSize.width) += _ALONG_SIDE_(_sizeOfCell.width);
        }
                
        [_sectionCellHeightCacheList addObject:_cellHeightCache];
        [_sectionCellsFrameCacheList addObject:[NSValue valueWithCGSize:_sectionSize]];
        
        _ALONG_SIDE_(_maxSectionSize.width) += _ALONG_SIDE_(_sectionSize.width);
        [_sectionCollapseStatusList addObject:[NSNumber numberWithBool:YES]];
    }
    _visiableSectionRect = CGRectZero;
    
    if ( _cycleEnabled == NO && _headSection != nil ) {
        _bottomSection = -2;
        _topSection = -1;
    }
    
    if (_footSection != nil) {
        [_footSection setSectionIndex:_sectionCount];
    }
    
    [self _visiableSectionsMoveWithOffset:CGSizeZero];
}

// Scroll to a cell at specified indexset and stick type.
- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexSet
                      stickType:(PYGridViewStickType)stick
                       animated:(BOOL)animated
{
    if ( [_visiableSections count] == 0 ) return;
    if ( indexSet.section >= [_visiableSections count] ) return;
    if ( [self _cellCountOfSection:indexSet.section] < indexSet.row ) return;
    
    // The key point is to calculate the offset.
//    CGFloat _scrollToTop = NAN;
//    CGFloat _scrollToBottom = NAN;
    
    if ( indexSet.section >= _topSection && indexSet.section <= _bottomSection ) {
        // In current visiable rect.
        for ( PYGridViewSection *_section in _visiableSections ) {
            if ( _section.sectionIndex == indexSet.section ) {
                
            }
        }
    }
    // Loop to get the route from top
    else if ( _cycleEnabled == YES || indexSet.section < _topSection ) {
        
    }
    
    if ( animated == NO ) {
        CGSize _offset = CGSizeZero;
        [self _visiableSectionsMoveWithOffset:_offset];
    }
}
// Scroll to specified offset
- (void)scrollToOffset:(CGFloat)offset animated:(BOOL)animated
{
    CGPoint _ctntOffset = self.contentOffset;
    _ALONG_SIDE_(_ctntOffset.x) = -_ALONG_SIDE_(_ctntOffset.x);
    offset *= -1;
    CGFloat _offset = _ALONG_SIDE_(_ctntOffset.x) - offset;
    
    if ( animated ) {
        _allMovingDistance = _offset;
        _animateOffset = [self
                          _startSpeedOfAllMovingDistance:_allMovingDistance
                          stepRate:_animateStep
                          timePieces:(_TS(1) / _TS(_animateTimeSpace))];
        [self _startToDecelerateScroll:1];
    } else {
        CGSize _offsetS = CGSizeZero;
        _ALONG_SIDE_(_offsetS.width) = _offset;
        [self _visiableSectionsMoveWithOffset:_offsetS];
    }
}

- (void)scrollToTop
{
    CGPoint _ctntOffset = self.contentOffset;
    CGSize _offset = CGSizeZero;
    _ALONG_SIDE_(_offset.width) = -_ALONG_SIDE_(_ctntOffset.x);
    _allMovingDistance = _ALONG_SIDE_(_offset.width);
    _animateOffset = [self
                      _startSpeedOfAllMovingDistance:_allMovingDistance
                      stepRate:_animateStep
                      timePieces:(_TS(.4) / _TS(_animateTimeSpace))];
    [self _startToDecelerateScroll:.4];
}

- (void)scrollToBottom
{
    CGSize _ctntSize = self.contentSize;
    CGPoint _ctntOffset = self.contentOffset;
    CGSize _offset = CGSizeZero;
    CGRect _b = self.bounds;
    _ALONG_SIDE_(_offset.width) = (_ALONG_SIDE_(_ctntSize.width) -
                                   _ALONG_SIDE_(_ctntOffset.x) -
                                   _ALONG_SIDE_SIZE(_b));
    _allMovingDistance = _ALONG_SIDE_(_offset.width);
    _animateOffset = [self
                      _startSpeedOfAllMovingDistance:_allMovingDistance
                      stepRate:_animateStep
                      timePieces:(_TS(.4) / _TS(_animateTimeSpace))];
    [self _startToDecelerateScroll:.4];
}

// Get the cell
- (PYGridViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    for ( PYGridViewSection *_section in _visiableSections ) {
        if ( _section.sectionIndex == indexPath.section ) {
            //_section.cellsInSection
            for ( PYGridViewCell *_cell in _section.cellsInSection ) {
                if ( [_cell.indexPath isEqual:indexPath] ) return _cell;
            }
            break;
        }
    }
    return nil;
}

// Get section view
- (UIView *)sectionViewAtIndex:(NSUInteger)index
{
    for ( PYGridViewSection *_section in _visiableSections ) {
        if ( _section.sectionIndex == index ) {
            return _section.sectionView;
        }
    }
    return nil;
}

// Collapse & Uncollapse section.
// If use collapse function, will force the section type
// switch to Block.
- (void)collapseSectionAtIndex:(NSUInteger)index
{
    
}
- (void)unCollapseSectionAtIndex:(NSUInteger)index
{
    
}

// Dequeue a cell from the cache.
- (PYGridViewCell *)dequeueCellForIdentify:(NSString *)identify
{
    @synchronized(self) {
        if ( [identify length] == 0 ) return nil;
        NSMutableSet *_cellSetOfIdentify = [_cellsCache objectForKey:identify];
        if ( _cellSetOfIdentify == nil ) return nil;
        if ( [_cellSetOfIdentify count] == 0 ) return nil;
        PYGridViewCell *_cachedCell = [_cellSetOfIdentify anyObject];
        [_cellSetOfIdentify removeObject:_cachedCell];
        return _cachedCell;
    }
}

// Cover View's sub view.
@synthesize coverView = _coverView;
- (void)coverViewAddSubView:(UIView *)subview
{
    [_coverView addSubview:subview];
}

#pragma mark --
#pragma mark Override
- (void)viewJustBeenCreated
{
    _visiableSectionRect = CGRectZero;
    _visiableSections = [NSMutableArray array];
    _willRemoveSections = [NSMutableArray array];
    _cellsCache = [NSMutableDictionary dictionary];
    _sectionCount = 0;
    
    // Animation
    _animateTimeSpace = .025;
    _animateStep = .9;
    _jellyAllTime = .4;
    
    _coverView = [[PYView alloc] init];
    [_coverView setBackgroundColor:[UIColor clearColor]];
    [_coverView setFrame:self.bounds];
    [self addSubview:_coverView];
    [_coverView setUserInteractionEnabled:NO];
    
    _bottomSection = -1;
    _topSection = 0;
    
    _sectionCellHeightCacheList = [NSMutableArray array];
    _sectionCellsFrameCacheList = [NSMutableArray array];
    _sectionHeadViewCacheList = [NSMutableArray array];
    _sectionCollapseStatusList = [NSMutableArray array];
    _sectionHeadFrameCacheList = [NSMutableArray array];
    _cellSelectedStatus = [NSMutableDictionary dictionary];
    _cycleEnabled = NO;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) {
        // Clear data
        [self clearData];
        return;
    }
    [self reloadData];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_coverView setFrame:self.bounds];
}

- (void)_startToDecelerateScroll:(CGFloat)allTime
{
    _allMovedDistance = 0.f;
    _scrollMaxStep = (_TS(allTime) / _TS(_animateTimeSpace));
    _scrollCurrentStep = 1;
    _canAnimateToNextOffset = YES;
    
    _animateScrollTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                   interval:_animateTimeSpace
                                                     target:self
                                                   selector:@selector(_animationScrollOffset)
                                                   userInfo:nil
                                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animateScrollTimer
                                 forMode:UITrackingRunLoopMode];
}

- (CGFloat)_distanceToMoveWithSpeed:(CGFloat)speed stepRate:(CGFloat)step timePieces:(NSUInteger)piece
{
    // D = S•(å•å^n - å)/(å - 1)
    CGFloat _distance = speed * (step * (powf(step, piece) - 1) / (step - 1.f));
#if DEBUG
    printf("The distance to move is: %f\n", _distance);
#endif
    return _distance;
}

- (CGFloat)_startSpeedOfAllMovingDistance:(CGFloat)distance stepRate:(CGFloat)step timePieces:(NSUInteger)piece
{
    // D = S•(å•å^n - å)/(å - 1)
    CGFloat _speed = distance / (step * (powf(step, piece) - 1) / (step - 1.f));
#if DEBUG
    printf("The speed of given distance is: %f\n", _speed);
#endif
    return _speed;
}

- (CGRect)_currentVisiableSectionRect
{
    CGRect _v = CGRectZero;
    int _vsc = [_visiableSections count];
    if ( _vsc > 0 ) {
        _v = ((PYGridViewSection *)[_visiableSections objectAtIndex:0]).sectionFrame;
        for ( int i = 1; i < _vsc; ++i ) {
            PYGridViewSection *_ = [_visiableSections objectAtIndex:i];
            _v = CGRectCombine(_v, _.sectionFrame);
        }
    }
    return _v;
}

- (void)_visiableSectionsMoveWithOffset:(CGSize)offset
{
    if ( _sectionCount == 0 ) return;
    CGFloat _offset = _ALONG_SIDE_(offset.width);
    BOOL _loadFromTop = (_offset <= 0) ? YES : NO;

    CGRect _b = self.bounds;
    CGFloat _staticSize = _STATIC_SIDE_SIZE(_b);
    
    if ( [_visiableSections count] == 0 ) {
        _visiableSectionRect = _b;
        _ALONG_SIDE_SIZE(_visiableSectionRect) = 0;
        if ( _loadFromTop == YES ) {
            _ALONG_SIDE_ORIGIN(_visiableSectionRect) -= _offset;
        } else {
            _ALONG_SIDE_ORIGIN(_visiableSectionRect) += (_ALONG_SIDE_SIZE(_b) - _offset);
        }
    } else {
        _visiableSectionRect = [self _currentVisiableSectionRect];
    }

    CGRect _willVisiableRect = _visiableSectionRect;
    _ALONG_SIDE_ORIGIN(_willVisiableRect) += _offset;
    
    while ( !CGRectInside(_b, _willVisiableRect) ) {
        // Get the loading section index.
        NSUInteger _sectionIndex = 0;
        if ( _loadFromTop ) {
            if ( _cycleEnabled == YES ) {
                // no header no footer,
                _bottomSection = (_bottomSection + 1) % _sectionCount;
            } else {
                if ( _footSection == nil ) {
                    if ( _bottomSection == _sectionCount - 1 ) break;
                    _bottomSection += 1;
                } else {
                    if ( _bottomSection == _sectionCount ) break;
                    _bottomSection += 1;
                }
            }
            _sectionIndex = _bottomSection;
        } else {
            if ( _cycleEnabled == YES ) {
                _topSection = (_topSection == 0) ? _sectionCount - 1 : _topSection - 1;
            } else {
                if ( _headSection == nil ) {
                    if ( _topSection == 0 ) break;
                    _topSection -= 1;
                } else {
                    if ( _topSection == -1 ) break;
                    _topSection -= 1;
                }
            }
            _sectionIndex = _topSection;
        }
        
        // Load the specified section.
        PYGridViewSection *_newSection = nil;
        if ( _sectionIndex == -1 ) _newSection = _headSection;
        else if ( _sectionIndex == _sectionCount ) _newSection = _footSection;
        else _newSection = [[PYGridViewSection alloc]
                            initSectionWithGridView:self
                            sectionIndex:_sectionIndex];

        // Calculate the will-be empty rect.
        CGRect _fakeSectionRect = _newSection.sectionFrame;
        if ( _loadFromTop ) {
            _ALONG_SIDE_ORIGIN(_fakeSectionRect) = (_ALONG_SIDE_ORIGIN(_visiableSectionRect) +
                                                     _ALONG_SIDE_SIZE(_visiableSectionRect));
        } else {
            _ALONG_SIDE_ORIGIN(_fakeSectionRect) = (_ALONG_SIDE_ORIGIN(_visiableSectionRect) -
                                                    _ALONG_SIDE_SIZE(_fakeSectionRect));
        }
        CGRect _willBeEmptyRect = CGRectCrop(_b, _fakeSectionRect, !_loadFromTop);
        
        _STATIC_SIDE_ORIGIN(_willBeEmptyRect) = 0.f;
        _ALONG_SIDE_SIZE(_willBeEmptyRect) = 0;
        _STATIC_SIDE_SIZE(_willBeEmptyRect) = _staticSize;
        
        // Initialize the section.
        [_newSection loadCellsWithinVisiableFrame:_willBeEmptyRect
                                          fromTop:_loadFromTop];
        
        if ( _loadFromTop ) {
            [_visiableSections addObject:_newSection];
        } else {
            [_visiableSections insertObject:_newSection atIndex:0];
        }
        
        // Update visiable frame.
        CGRect _newSectionFrame = _newSection.sectionFrame;
        CGFloat _appendSize = *(&_newSectionFrame.size.width + _scrollType);
        _ALONG_SIDE_SIZE(_visiableSectionRect) += _appendSize;
        if ( _loadFromTop != YES ) {
            _ALONG_SIDE_ORIGIN(_visiableSectionRect) -= _appendSize;
        }
        _willVisiableRect = _visiableSectionRect;
        _ALONG_SIDE_ORIGIN(_willVisiableRect) += _offset;
    }
    
    // Move sections and re-caluclate the visiable frame
    for ( PYGridViewSection *_section in _visiableSections ) {
        CGRect _willMoveToFrame = _section.sectionFrame;
        _ALONG_SIDE_ORIGIN(_willMoveToFrame) += _offset;
        BOOL _isJoined = CGRectJoined(_willMoveToFrame, _b);
        
        CGRect _canBeSeenFrame = CGRectZero;
        if ( _isJoined ) {
            _canBeSeenFrame = CGRectCrop(_willMoveToFrame, _b, NO);
        }
        
        [_section visiableSectionMoveToOffset:offset withVisiableFrame:_canBeSeenFrame];
        
        if ( !_isJoined ) {
            [_willRemoveSections addObject:_section];
        }
    }
    
    for ( PYGridViewSection *_section in _willRemoveSections ) {
        [_section removeSectionFromGridView];
        [_visiableSections removeObject:_section];
    }
    
    [_willRemoveSections removeAllObjects];
    
    if ( [self.delegate respondsToSelector:@selector(gridViewDidScroll:)] ) {
        [self.delegate gridViewDidScroll:self];
    }
    
    if ( [_visiableSections count] > 0 ) {
        PYGridViewSection *_topLoadedSection = [_visiableSections objectAtIndex:0];
        _topSection = _topLoadedSection.sectionIndex;
        PYGridViewSection *_bottomLoadedSection = [_visiableSections lastObject];
        _bottomSection = _bottomLoadedSection.sectionIndex;
    }
}

- (void)_animationScrollDidStop:(PYGridView *)gridView
{
    if ( _jellyEffectiveOn == YES ) {
        _jellyEffectiveOn = NO;
        // Set goback offset, do again
        _animateOffset = [self _startSpeedOfAllMovingDistance:_ALONG_SIDE_(_jellyBackOffset.width)
                                                     stepRate:_animateStep
                                                   timePieces:(_TS(_jellyAllTime) / _TS(_animateTimeSpace))];
        [self _startToDecelerateScroll:_jellyAllTime];
    } else {
        _userDraging = NO;
        CFRunLoopStop(CFRunLoopGetMain());
        
        if ( [self.delegate respondsToSelector:@selector(gridViewDidEndDecelerate:)] ) {
            [self.delegate gridViewDidEndDecelerate:self];
        }
    }
}

- (void)_animationScrollOffset
{
    CGFloat _fn = _animateOffset * powf(_animateStep, _scrollCurrentStep);
    _scrollCurrentStep += 1;
    if ( _scrollCurrentStep == _scrollMaxStep ) {
        _fn = _allMovingDistance - _allMovedDistance;
    } else {
        _allMovedDistance += _fn;
    }
    CGSize _offset = CGSizeZero;
    _ALONG_SIDE_(_offset.width) = _fn;
    if ( _scrollCurrentStep > _scrollMaxStep ) {
        [_animateScrollTimer invalidate];
        _animateScrollTimer = nil;
        [self _animationScrollDidStop:self];
        return;
    }

    [CATransaction begin];
    [CATransaction setAnimationDuration:_animateTimeSpace];
    [CATransaction
     setAnimationTimingFunction:
     [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionLinear]];
    [self _visiableSectionsMoveWithOffset:_offset];
    [CATransaction commit];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [touches count] > 1 ) {
        [self.nextResponder touchesMoved:touches withEvent:event];
        return;
    }
    
    _userDraging = YES;
    _lastTouchPoint = [[touches anyObject] locationInView:self];
    _touchBeginPoint = _lastTouchPoint;
    _moved = NO;
    _canAnimateToNextOffset = NO;
    _jellyEffectiveOn = NO;

    if ( _animateScrollTimer != nil ) {
        [_animateScrollTimer invalidate];
        _animateScrollTimer = nil;
    }
    
    gettimeofday(&_startTime, NULL);
    
    if ( [self.delegate respondsToSelector:@selector(gridViewDidBeginDraging:)] ) {
        [self.delegate gridViewDidBeginDraging:self];
    }

    while ( _userDraging &&
           [[NSRunLoop currentRunLoop] runMode:UITrackingRunLoopMode
                                    beforeDate:[NSDate distantFuture]]);
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [touches count] > 1 ) {
        [self.nextResponder touchesMoved:touches withEvent:event];
        return;
    }
    
    CGPoint _movePoint = [[touches anyObject] locationInView:self];
    _moved = YES;

    CGSize _offset = CGSizeZero;
    int _nagetive = ((_ALONG_SIDE_(_movePoint.x) - _ALONG_SIDE_(_touchBeginPoint.x))
                     < 0 ? -1 : 1);
    CGFloat _moveValue = (powf(ABS(_ALONG_SIDE_(_movePoint.x) -
                                   _ALONG_SIDE_(_touchBeginPoint.x)),
                               _GRID_MOVE_EXPONENTIAL_) * _nagetive);
    _nagetive = ((_ALONG_SIDE_(_lastTouchPoint.x) - _ALONG_SIDE_(_touchBeginPoint.x))
                 < 0 ? -1 : 1);
    CGFloat _lastMoveValue = (powf(ABS(_ALONG_SIDE_(_lastTouchPoint.x) -
                                       _ALONG_SIDE_(_touchBeginPoint.x)),
                                   _GRID_MOVE_EXPONENTIAL_) * _nagetive);
    _ALONG_SIDE_(_offset.width) = _moveValue - _lastMoveValue;
    
    [self _visiableSectionsMoveWithOffset:_offset];
    _lastTouchPoint = _movePoint;

    // Calculate moving speed.
    gettimeofday(&_endTime, NULL);
    CGFloat _timePassed = 0.f;
    _timePassed = ((double)(1000000.f * (_endTime.tv_sec - _startTime.tv_sec)) +
                   (double)(_endTime.tv_usec - _startTime.tv_usec));
	_timePassed /= 1000.f;
    // Per-second
    _movingSpeed = (_offset.width + _offset.height) / _timePassed;
    
    // Retick
    gettimeofday(&_startTime, NULL);
}

- (void)_touchRelease:(NSSet *)touches;
{
    // Animation.
    //if ( _moved == NO ) return;
    _animateOffset = _movingSpeed * 100;
    
    if ( _pageEnabled ) {
        // Recalculate the animate offset.
        // Try to calculate all moving distance
        _allMovingDistance = [self
                              _distanceToMoveWithSpeed:_animateOffset
                              stepRate:_animateStep
                              timePieces:(_TS(_GRID_SCROLL_ANIMATION_ALLTIME) / _TS(_animateTimeSpace))];
        
        BOOL _scrollToMore = (_animateOffset < 0);
        PYGridViewSection *_stickSection = (_scrollToMore ?
                                            [_visiableSections lastObject] :
                                            [_visiableSections objectAtIndex:0]);
        if ( _scrollToMore == YES ) {
            NSUInteger _checkSection = _stickSection.sectionIndex;
            CGRect _checkFrame = _stickSection.sectionFrame;
            _ALONG_SIDE_ORIGIN(_checkFrame) += _allMovingDistance;
            CGPoint _checkPoint = CGPointMake(self.bounds.size.width, self.bounds.size.height);
            CGRect _checkCornerRect = CGRectMake(_checkPoint.x, _checkPoint.y, 0, 0);
            int _bottomLimit = (_cycleEnabled == NO ?
                                (_footSection == nil ? _sectionCount : _sectionCount + 1) :
                                _sectionCount);
            do {
                if ( CGRectInside(_checkCornerRect, _checkFrame) ) {
                    break;
                }
                // Get next section
                _checkSection = (_checkSection + 1) % _bottomLimit;
                CGFloat _nextSize = [self _sectionRealtimeSizeAtIndex:_checkSection];
                _ALONG_SIDE_ORIGIN(_checkFrame) += _ALONG_SIDE_SIZE(_checkFrame);
                _ALONG_SIDE_SIZE(_checkFrame) = _nextSize;
            } while ( 1 );
            // Get the section...
            // _checkSection it is!!!!
            CGRect _tempRect = CGRectZero;
            _tempRect.origin = _checkFrame.origin;
            
            _tempRect.size = [self _sectionHeadFrameAtIndex:_checkSection];
            _STATIC_SIDE_SIZE(_tempRect) = _STATIC_SIDE_SIZE(_visiableSectionRect);
            // If the section is uncollapsed, so the section header must contain the check point
            // according to the formar alogrithm.
            if ( !CGRectInside(_checkCornerRect, _tempRect) ) {
                // Loop to check the cells
                NSUInteger _cellIndex = 0;
                NSMutableArray *_cellSizeCache = [self _cellsSizeCacheInSection:_checkSection];
                do {
                    NSValue *_sv = [_cellSizeCache objectAtIndex:_cellIndex];
                    CGSize _cellSize = CGSizeZero;
                    [_sv getValue:&_cellSize];
                    _ALONG_SIDE_ORIGIN(_tempRect) += _ALONG_SIDE_SIZE(_tempRect);
                    _ALONG_SIDE_SIZE(_tempRect) = _ALONG_SIDE_(_cellSize.width);
                    
                    if ( CGRectInside(_checkCornerRect, _tempRect) ) {
                        break;
                    }
                    
                    ++_cellIndex;
                } while( _cellIndex < [_cellSizeCache count] );
            }
            
            // So I get the finally temp rect.
            CGFloat _topMargin = _ALONG_SIDE_ORIGIN(_checkCornerRect) - _ALONG_SIDE_ORIGIN(_tempRect);
            CGFloat _bottomMargin = _ALONG_SIDE_SIZE(_tempRect) - _topMargin;
            if ( _topMargin < _bottomMargin ) {
                _allMovingDistance += _topMargin;
            } else {
                _allMovingDistance -= _bottomMargin;
            }
        } else {
            // to up...
            NSUInteger _checkSection = _stickSection.sectionIndex;
            CGRect _checkFrame = _stickSection.sectionFrame;
            _ALONG_SIDE_ORIGIN(_checkFrame) += _allMovingDistance;
            CGRect _checkCornerRect = CGRectZero;
            int _topLimit = 0;
            if (_cycleEnabled == NO && _headSection != nil)
                _topLimit = -1;
            do {
                if ( CGRectInside(_checkCornerRect, _checkFrame) ) {
                    break;
                }
                // Get next section
                if ( _checkSection == _topLimit ) _checkSection = _sectionCount;
                _checkSection -= 1;
                CGFloat _nextSize = [self _sectionRealtimeSizeAtIndex:_checkSection];
                _ALONG_SIDE_ORIGIN(_checkFrame) -= _nextSize;
                _ALONG_SIDE_SIZE(_checkFrame) = _nextSize;
            } while ( 1 );
            
            CGRect _tempRect = CGRectZero;
            _tempRect.origin = _checkFrame.origin;
            _ALONG_SIDE_ORIGIN(_tempRect) += _ALONG_SIDE_SIZE(_checkFrame);
            _STATIC_SIDE_SIZE(_tempRect) = _STATIC_SIDE_SIZE(_visiableSectionRect);
            
            // I need to check the cells directly.
            // for the last one, check the section header view.
            // Loop to check the cells
            NSMutableArray *_cellSizeCache = [self _cellsSizeCacheInSection:_checkSection];
            int _cellIndex = [_cellSizeCache count] - 1;
            do {
                if ( [_cellSizeCache count] == 0 ) break;
                NSValue *_sv = [_cellSizeCache objectAtIndex:_cellIndex];
                CGSize _cellSize = CGSizeZero;
                [_sv getValue:&_cellSize];
                _ALONG_SIDE_ORIGIN(_tempRect) -= _ALONG_SIDE_(_cellSize.width);
                _ALONG_SIDE_SIZE(_tempRect) = _ALONG_SIDE_(_cellSize.width);
                
                if ( CGRectInside(_checkCornerRect, _tempRect) ) {
                    break;
                }
                if ( _cellIndex == 0 ) {
                    _cellIndex = (NSUInteger)-1;
                    break;
                }
                --_cellIndex;
            } while( _cellIndex < [_cellSizeCache count] );
            
            // Check the section size if _cellIndex is nagetive.
            if ( _cellIndex < 0 ) {
                _tempRect.size = [self _sectionHeadFrameAtIndex:_checkSection];
                _STATIC_SIDE_SIZE(_tempRect) = _STATIC_SIDE_SIZE(_checkFrame);
                _ALONG_SIDE_ORIGIN(_tempRect) -= _ALONG_SIDE_SIZE(_tempRect);
                if ( !CGRectInside(_checkCornerRect, _tempRect) ) {
                    NSLog(@"Fuck!! What happend!");
                }
            }
            
            // So I get the finally temp rect.
            CGFloat _topMargin = _ALONG_SIDE_ORIGIN(_checkCornerRect) - _ALONG_SIDE_ORIGIN(_tempRect);
            CGFloat _bottomMargin = _ALONG_SIDE_SIZE(_tempRect) - _topMargin;
            if ( _topMargin < _bottomMargin ) {
                _allMovingDistance += _topMargin;
            } else {
                _allMovingDistance -= _bottomMargin;
            }
        }

        if ( _allMovingDistance == 0 ) {
            _userDraging = NO;
            CFRunLoopStop(CFRunLoopGetMain());
            return;
        }
        
        _animateOffset = [self
                          _startSpeedOfAllMovingDistance:_allMovingDistance
                          stepRate:_animateStep
                          timePieces:(_TS(_GRID_SCROLL_ANIMATION_ALLTIME) / _TS(_animateTimeSpace))];
    }
    
    _allMovingDistance = [self
                          _distanceToMoveWithSpeed:_animateOffset
                          stepRate:_animateStep
                          timePieces:(_TS(_GRID_SCROLL_ANIMATION_ALLTIME) / _TS(_animateTimeSpace))];
    if ( _allMovingDistance == 0 ) {
        _userDraging = NO;
        CFRunLoopStop(CFRunLoopGetMain());
        return;
    }
    if ( _cycleEnabled == NO ) {
        if ( [_visiableSections count] == 0 ) {
            _visiableSectionRect = CGRectZero;
        } else {
            _visiableSectionRect = [self _currentVisiableSectionRect];
        }
        CGRect _willVisiableRect = _visiableSectionRect;
        _ALONG_SIDE_ORIGIN(_willVisiableRect) += _allMovingDistance;
        if ( [_visiableSections count] == 0 ) {
            _bottomSection = _sectionCount;
            _topSection = _bottomSection;
        }
        int _currentTop = _topSection;
        int _topLimit = _headSection == nil ? 0 : -1;
        CGFloat _topLeftSpace = 0.f;
        while ( _currentTop > _topLimit ) {
            _topLeftSpace += [self _sectionRealtimeSizeAtIndex:(_currentTop -= 1)];
        }
        NSUInteger _currentBottom = _bottomSection;
        CGFloat _bottomLeftSpace = 0.f;
        int _bottomLimit = _footSection == nil ? _sectionCount - 1 : _sectionCount;
        while ( _currentBottom < _bottomLimit ) {
            _bottomLeftSpace += [self _sectionRealtimeSizeAtIndex:(_currentBottom += 1)];
        }
        
        _ALONG_SIDE_ORIGIN(_willVisiableRect) -= _topLeftSpace;
        _ALONG_SIDE_SIZE(_willVisiableRect) += (_topLeftSpace + _bottomLeftSpace);
        
        CGRect _nowVisiableRect = _visiableSectionRect;
        _ALONG_SIDE_ORIGIN(_nowVisiableRect) -= _topLeftSpace;
        _ALONG_SIDE_SIZE(_nowVisiableRect) += (_topLeftSpace + _bottomLeftSpace);
        CGRect _b = self.bounds;
        
        for ( ; ; ) {
            if ( CGRectInside(_b, _willVisiableRect) ) break;
            
            if ( (_ALONG_SIDE_SIZE(_willVisiableRect) <= _ALONG_SIDE_SIZE(_b)) ||
                (_ALONG_SIDE_ORIGIN(_visiableSectionRect) > 0 && _topSection == _topLimit) ) {
                // Stick to top
                CGSize _offToTop = CGSizeZero;
                _ALONG_SIDE_(_offToTop.width) = -(_ALONG_SIDE_ORIGIN(_nowVisiableRect));
                
                if ( [self.delegate respondsToSelector:
                      @selector(gridViewDidEndDrag:willDecelerateOffset:)] ) {
                    [self.delegate gridViewDidEndDrag:self willDecelerateOffset:_offToTop];
                }
                _animateOffset = [self
                                  _startSpeedOfAllMovingDistance:_ALONG_SIDE_(_offToTop.width)
                                  stepRate:_animateStep
                                  timePieces:(_TS(.3) / _TS(_animateTimeSpace))];
                [self _startToDecelerateScroll:.3];
                return;
            }
            
            if ( (_ALONG_SIDE_ORIGIN(_nowVisiableRect) +
                  _ALONG_SIDE_SIZE(_nowVisiableRect))
                < (_ALONG_SIDE_SIZE(_b)) ) {
                CGSize _offToBottom = CGSizeZero;
                _ALONG_SIDE_(_offToBottom.width) = ((_ALONG_SIDE_SIZE(_b)) -
                                                    (_ALONG_SIDE_ORIGIN(_visiableSectionRect) +
                                                    _ALONG_SIDE_SIZE(_visiableSectionRect)));
                if ( [self.delegate respondsToSelector:
                      @selector(gridViewDidEndDrag:willDecelerateOffset:)] ) {
                    [self.delegate gridViewDidEndDrag:self willDecelerateOffset:_offToBottom];
                }
                _animateOffset = [self
                                  _startSpeedOfAllMovingDistance:_ALONG_SIDE_(_offToBottom.width)
                                  stepRate:_animateStep
                                  timePieces:(_TS(.3) / _TS(_animateTimeSpace))];
                [self _startToDecelerateScroll:.3];
                return;
            }
            
            CGFloat _o = 0.f;
            if ( _allMovingDistance > 0 ) {
                _o = -_ALONG_SIDE_ORIGIN(_nowVisiableRect);
            } else {
                _o = (_ALONG_SIDE_ORIGIN(_nowVisiableRect) +
                      _ALONG_SIDE_SIZE(_nowVisiableRect) -
                      _ALONG_SIDE_SIZE(_b));
            }
            CGFloat _maxOffset = powf((ABS(_allMovingDistance) - _o), .4) + _o;
            CGFloat _goBackOffset = _maxOffset - _o;
            _maxOffset = _maxOffset * (_allMovingDistance > 0 ? 1 : -1);
            _goBackOffset = _goBackOffset * (_maxOffset > 0 ? -1 : 1);
            CGSize _offToMax = CGSizeZero;
            _ALONG_SIDE_(_offToMax.width) = _maxOffset;
            CGSize _offGoBack = CGSizeZero;
            _ALONG_SIDE_(_offGoBack.width) = _goBackOffset;
            
            if ( [self.delegate respondsToSelector:
                  @selector(gridViewDidEndDrag:willDecelerateOffset:)] ) {
                [self.delegate gridViewDidEndDrag:self willDecelerateOffset:_offGoBack];
            }
            _animateOffset = [self _startSpeedOfAllMovingDistance:_maxOffset
                                                         stepRate:_animateStep
                                                       timePieces:(_TS(_jellyAllTime) / _TS(_animateTimeSpace))];
            _jellyEffectiveOn = YES;
            _jellyBackOffset = _offGoBack;
            [self _startToDecelerateScroll:_jellyAllTime];
            return;
        }        
    }
    CGRect _b = self.bounds;
    CGFloat _timeToScroll = _GRID_SCROLL_ANIMATION_ALLTIME;
    if ( ABS(_allMovingDistance) < (_ALONG_SIDE_SIZE(_b) / 3) ) {
        _timeToScroll = .3;
        _animateOffset = [self _startSpeedOfAllMovingDistance:_allMovingDistance
                                                     stepRate:_animateStep
                                                   timePieces:(_TS(_timeToScroll) / _TS(_animateTimeSpace))];
    }
    
    CGSize _o = CGSizeZero;
    _ALONG_SIDE_(_o.width) = _allMovingDistance;
    if ( [self.delegate respondsToSelector:
          @selector(gridViewDidEndDrag:willDecelerateOffset:)] ) {
        CGSize _o = CGSizeZero;
        _ALONG_SIDE_(_o.width) = _allMovingDistance;
        [self.delegate gridViewDidEndDrag:self willDecelerateOffset:_o];
    }
    
    [self _startToDecelerateScroll:_timeToScroll];
    /*
    [UIView animateWithDuration:_timeToScroll animations:^{
        [self _visiableSectionsMoveWithOffset:_o];
    }];
    */
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _touchRelease:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _touchRelease:touches];
}

@end
