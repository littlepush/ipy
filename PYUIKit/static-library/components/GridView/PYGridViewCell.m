//
//  PYGridViewCell.m
//  PYUIKit
//
//  Created by Push Chen on 5/15/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYGridViewCell.h"
#import "UIColor+PYUIKit.h"
#import "PYGridView+Internal.h"
#import "UIView+PYUIKit.h"

static NSArray *_gridViewCellBlue;
static NSArray *_gridViewCellGray;

@implementation PYGridViewCell

+ (void)initialize
{
    _gridViewCellBlue = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithString:@"#1E7CB1"].CGColor,
                         (id)[UIColor colorWithString:@"#64ADD8"].CGColor,
                         nil];
    _gridViewCellGray = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithString:@"#B3BCCA"].CGColor,
                         (id)[UIColor colorWithString:@"#C8D1DC"].CGColor,
                         nil];
}

- (void)_editButtonTouchUpInside:(id)sender
{
    if ( _didDeleted ) _didDeleted(self);
}

- (void)_selectTapGestureHandler:(id)sender
{
    [[self parentGridView] _didSelectedCell:self atIndex:_indexPath];
}

- (void)_editSwipeGestureHandler:(id)sender
{
    if ( _isEditing ) {
        [self setEditStatus:NO animated:YES];
        if ( _endToEdit ) _endToEdit(self);
    } else {
        [self setEditStatus:YES animated:YES];
        if ( _beginToEdit ) _beginToEdit(self);
    }
}

- (void)viewJustBeenCreated
{
    [self setClipsToBounds:YES];
    [self setUserInteractionEnabled:YES];
    _selectedLayer = [CAGradientLayer layer];
    [self.layer addSublayer:_selectedLayer];
    [_selectedLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [_selectedLayer setFrame:self.bounds];
    
    // Add Tap gesture
    UITapGestureRecognizer *_tGesture = nil;
    _tGesture = [[UITapGestureRecognizer alloc]
                 initWithTarget:self
                 action:@selector(_selectTapGestureHandler:)];
    [self addGestureRecognizer:_tGesture];    
}

- (id)initCellWithReusableIdentify:(NSString *)identify
{
    self = [super init];
    if ( self ) {
        _reusableIdentify = [identify copy];
    }
    return self;
}

@synthesize reusableIdentify = _reusableIdentify;
// The selection style
@synthesize selectionStyle = _selectionStyle;

// Grid Info
@dynamic parentGridView;
- (PYGridView *)parentGridView
{
    return (PYGridView *)(self.superview.superview);
}
@synthesize indexPath = _indexPath;

// Title
@dynamic textLabel;
- (PYLabelLayer *)textLabel
{
    if ( _textLabel == nil ) {
        _textLabel = [PYLabelLayer layer];
        [self.layer addSublayer:_textLabel];
        [_textLabel setFrame:self.bounds];
        [_textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _textLabel;
}

// Editable
@synthesize editEnabled = _editEnabled;
- (void)setEditEnabled:(BOOL)enable
{
    _editEnabled = enable;
    if ( _editEnabled == YES ) {
        if ( _editButton == nil ) {
            _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat _padding = 5.f; // static
            CGRect _buttonFrame = CGRectMake(0, 0, 44.f, 31.f);
            CGRect _myBounds = self.bounds;
            _buttonFrame.origin.x = _myBounds.size.width - _padding - _buttonFrame.size.width;
            _buttonFrame.size.height = _myBounds.size.height - (_padding * 2);
            _buttonFrame.origin.y = _padding;
            [_editButton setFrame:_buttonFrame];
            [_editButton setBackgroundColor:[UIColor redColor]];
            [_editButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [_editButton.layer setBorderWidth:.5f];
            [_editButton.titleLabel setTextColor:[UIColor whiteColor]];
            [_editButton.titleLabel setText:@"Delete"];
        }
        
        if ( _swipeGesture == nil ) {
            _swipeGesture = [[UISwipeGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(_editSwipeGestureHandler:)];
            [_swipeGesture setDirection:
             (UISwipeGestureRecognizerDirectionLeft |
              UISwipeGestureRecognizerDirectionRight)];
        }
        [self addGestureRecognizer:_swipeGesture];
        
        // Set transform
        CGAffineTransform _transform = CGAffineTransformMakeScale(.01, 1.f);
        _transform = CGAffineTransformTranslate(_transform, CGRectGetWidth(_editButton.bounds) / 2, 0);
        [_editButton setTransform:_transform];
        
        if ( _editButton.superview == nil ) {
            [self addSubview:_editButton];
        }
    } else {
        if ( _swipeGesture != nil ) {
            [self removeGestureRecognizer:_swipeGesture];
        }
        if ( _editButton == nil ) return;
        [_editButton removeFromSuperview];
        _editButton.transform = CGAffineTransformIdentity;
    }
}
@synthesize isEditing = _isEditing;
- (void)setIsEditing:(BOOL)editing
{
    [self setEditStatus:editing animated:NO];
}
- (void)setEditButton:(UIButton *)button
{
    if ( _editButton != nil ) {
        [_editButton removeFromSuperview];
        _editButton = nil;
    }
    _editButton = button;
    [_editButton addTarget:self action:@selector(_editButtonTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];

    // Set button frame
    CGRect _buttonFrame = _editButton.frame;
    CGRect _myBounds = self.bounds;
    CGFloat _padding = (_myBounds.size.height - _buttonFrame.size.height) / 2;
    _buttonFrame.origin.x = _myBounds.size.width - _buttonFrame.size.width - _padding;
    _buttonFrame.origin.y = _padding;
    
    if ( _isEditing == YES ) {
        [self addSubview:_editButton];
    }
}
- (void)setEditStatus:(BOOL)editing animated:(BOOL)animated
{
    if ( _editEnabled == NO ) return;
    _isEditing = editing;
    if ( animated ) {
        [UIView beginAnimations:@"CellEditStatusChange" context:NULL];
        [UIView setAnimationDuration:.25];
    }
    
    if ( _isEditing ) {
        [_editButton setTransform:CGAffineTransformIdentity];
    } else {
        CGAffineTransform _transform = CGAffineTransformMakeScale(.01, 1.f);
        _transform = CGAffineTransformTranslate(_transform, CGRectGetWidth(_editButton.bounds) / 2, 0);
        [_editButton setTransform:_transform];
    }
    
    if ( animated ) {
        [UIView commitAnimations];
    }
}

// Selection
@synthesize isSelected = _isSelected;
- (void)setIsSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

// Set selection
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _isSelected = selected;
    
    if ( animated ) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:.1];
    }
    
    if ( selected == YES ) {
        if ( _selectionStyle == PYGridViewCellSelectionStyleNone ) {
            // Nothing
            [_selectedLayer setColors:nil];
        } else if ( _selectionStyle == PYGridViewCellSelectionStyleBlue ) {
            [_selectedLayer setColors:_gridViewCellBlue];
        } else if ( _selectionStyle == PYGridViewCellSelectionStyleGray ) {
            [_selectedLayer setColors:_gridViewCellGray];
        }
    } else {
        [_selectedLayer setColors:nil];
    }
    
    if ( animated ) {
        [CATransaction commit];
    }
}

@synthesize realFrame = _realFrame;

// Override
- (void)prepareForReuse
{
    
}
- (void)cellJustBeenCreated
{
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _realFrame = frame;
    if ( _selectedLayer != nil ) {
        [_selectedLayer setFrame:self.bounds];
    }
    if ( _textLabel != nil ) {
        [_textLabel setFrame:self.bounds];
    }
}

- (CGRect)frame
{
    CGRect _myFrame = _realFrame;
    CGRect _invisiableFrame = self.superview.frame;
    _myFrame.origin.x += _invisiableFrame.origin.x;
    _myFrame.origin.y += _invisiableFrame.origin.y;
    return _myFrame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil ) return;
    if ( _textLabel != nil ) {
        [_textLabel setNeedsDisplay];
    }
}

@end
