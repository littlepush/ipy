//
//  PYSlider.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/1/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYComponentView.h"

@protocol PYSliderDelegate;

@interface PYSlider : PYComponentView
{
	UIImageView				*_backgroundView;
	UIImageView				*_slideButton;
	UIImageView				*_minTrackTint;
	UIImageView				*_maxTrackTint;

	UIImage					*_minTrackTintImage;
	CGFloat					_minimum;
	CGFloat					_maximum;

	id<PYSliderDelegate>	_delegate;
}

@property (nonatomic, retain)	UIImage 		*backgroundImage;
@property (nonatomic, retain)	UIImage 		*slideButtonImage;
@property (nonatomic, retain)	UIColor			*slideButtonColor;
@property (nonatomic, retain)	UIImage 		*minTrackTintImage;
@property (nonatomic, retain)	UIImage 		*maxTrackTintImage;
@property (nonatomic, retain)	UIColor			*minTrackTintColor;
@property (nonatomic, retain)	UIColor			*maxTrackTintColor;
@property (nonatomic, assign)	CGFloat			minimum;
@property (nonatomic, assign)	CGFloat			maximum;
@property (nonatomic, readonly)	CGFloat			currentValue;
@property (nonatomic, retain)	IBOutlet id<PYSliderDelegate>	delegate;


/* Initial Slide View */
-(id) initWithMinimum:(CGFloat)min Maximum:(CGFloat)max Current:(CGFloat)val;

/* set current value with animation */
-(void) setCurrentValue:(CGFloat)aValue animated:(BOOL)animated;

@end

@protocol PYSliderDelegate <NSObject>

@optional
-(void) pySlider:(PYSlider *)slider valueChangedTo:(CGFloat)value;

@end
