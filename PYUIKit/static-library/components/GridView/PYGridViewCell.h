//
//  PYGridViewCell.h
//  PYUIKit
//
//  Created by Push Chen on 5/15/13.
//  Copyright (c) 2013 Markphone Culture Media Co.Ltd. All rights reserved.
//

#import "PYView.h"
#import "PYGridView.h"
#import "PYLabelLayer.h"

typedef enum {
    PYGridViewCellSelectionStyleNone        = 0,
    PYGridViewCellSelectionStyleBlue,
    PYGridViewCellSelectionStyleGray
} PYGridViewCellSelectionStyle;

// The cell action block
typedef void (^_gridViewCellAction)(PYGridViewCell *cell);

@interface PYGridViewCell : PYView
{
    NSString                                *_reusableIdentify;
    CAGradientLayer                         *_selectedLayer;
    
    @protected
    // Which should be the superview.
    PYGridViewCellSelectionStyle            _selectionStyle;
    NSIndexPath                             *_indexPath;
    PYLabelLayer                            *_textLabel;
    
    BOOL                                    _editEnabled;
    BOOL                                    _isSelected;
    UIButton                                *_editButton;
    
    UISwipeGestureRecognizer                *_swipeGesture;
    
    _gridViewCellAction                     _beginToEdit;
    _gridViewCellAction                     _endToEdit;
    _gridViewCellAction                     _didSelected;
    _gridViewCellAction                     _didDeleted;
    
    CGRect                                  _realFrame;
}

// Initialize
- (id)initCellWithReusableIdentify:(NSString *)identify;
@property (nonatomic, readonly) NSString                        *reusableIdentify;

// The selection style
@property (nonatomic, assign)   PYGridViewCellSelectionStyle    selectionStyle;

// Grid Info
@property (nonatomic, readonly) PYGridView                      *parentGridView;
@property (nonatomic, readonly) NSIndexPath                     *indexPath;

// Title
@property (nonatomic, readonly) PYLabelLayer                    *textLabel;

// Editable
@property (nonatomic, assign)   BOOL                            editEnabled;
@property (nonatomic, assign)   BOOL                            isEditing;
- (void)setEditStatus:(BOOL)editing animated:(BOOL)animated;
// Set the cusomized button.
- (void)setEditButton:(UIButton *)button;

// Selection
@property (nonatomic, assign)   BOOL                            isSelected;

@property (nonatomic, readonly) CGRect                          realFrame;

// Set selection
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

// Override
- (void)prepareForReuse;
- (void)cellJustBeenCreated;

@end
