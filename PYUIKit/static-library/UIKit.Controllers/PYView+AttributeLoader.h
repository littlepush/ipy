//
//  PYView+AttributeLoader.h
//  PYUIKit
//
//  Created by Push Chen on 11/13/13.
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

#import <PYUIKit/PYUIKit.h>
#import "PYView.h"
#import "PYScrollView.h"
#import "PYTableView.h"
#import "PYSlider.h"
#import "PYSwitcher.h"
#import "PYLabelLayer.h"
#import "PYLabel.h"
#import "PYImageLayer.h"
#import "PYImageView.h"

// Attributes support by PYView
// Basicly, PYView is a UIView, so it will rend the view use super call first.
// PYView support some specified attributes also.
//  innerShadowColor: NSString object, a UIColor option string
//  innerShadowPadding: NSString object, a PYPadding string, {l, r, t, b}
@interface PYView (AttributeLoader)
+ (void)rendView:(PYView *)view withOption:(NSDictionary *)option;
@end

// Attribute support by PYScrollView
// A PYScrollView is inherited from PYView, and in addition, it support
// the following attributes:
//  pageSize: NSString object, a CGSize string {w, h}
//  isPagable: bool object
//  maxDeceleratePageCount: Integer object
//  scrollSide: NSString object, [freedom/horizontal/verticalis]
//  decelerateSpeed: NSString object, [none/very slow/slow/normal/fast/very fast]
@interface PYScrollView (AttributeLoader)
+ (void)rendView:(PYScrollView *)scrollView withOption:(NSDictionary *)option;
@end

// Attribute support by PYTableView
// A PYTableView is a PYScrollView, in addition, support the following attribute:
//  loop: bool object, means if the table should loop to display its content.
@interface PYTableView (AttributeLoader)
+ (void)rendView:(PYTableView *)tableView withOption:(NSDictionary *)option;
@end

// Not implemented yet.
@interface PYSlider (AttributeLoader)
+ (void)rendView:(PYSlider *)slider withOption:(NSDictionary *)option;
@end

// Attribute support by PYSwitcher
//  backgroundImage: NSString object, an image name, loaded by PYResource
//  buttonImage: NSString object, an image name, loaded by PYResource
//  leftLabel: NSDictionary object, the left label's rending option
//  rightLabel: NSDictionary object, the right label's rending option
@interface PYSwitcher (AttributeLoader)
+ (void)rendView:(PYSwitcher *)switcher withOption:(NSDictionary *)option;
@end

// Attribute support by PYLabelLayer
// The PYLabelLayer can be considered as a UILabel, and in addition
// supports the following extended attributes:
//  textShadow: NSDictionary object, includes:
//      offset: NSString object, a CGSize string, {w, h}
//      color: NSString object, a UIColor option string
//      radius: float object
//  textBorder: NSDictionary object, includes:
//      borderWidth: float object
//      borderColor: NSString object, a UIColor option string
//  paddingLeft: float object
//  paddingRight: float object
//  multipleLine: bool object
@interface PYLabelLayer (AttributeLoader)
+ (void)rendLayer:(PYLabelLayer *)labelLayer withOption:(NSDictionary *)option;
@end

// Attribute support by PYLabel
// A PYLabel is just a shell of PYLabelLayer, they use the same option attributes.
@interface PYLabel (AttributeLoader)
+ (void)rendView:(PYLabel *)label withOption:(NSDictionary *)option;
@end

// Attribute support by PYImageLayer
//  image: NSString object, an image name, load by PYResource
//  placehold: NSString object, an image name, load by PYResource
//  imageUrl: NSString object, if set [image], then the imageUrl will be ignore.
@interface PYImageLayer (AttributeLoader)
+ (void)rendLayer:(PYImageLayer *)imageLayer withOption:(NSDictionary *)option;
@end

// Attribute support by PYImageView
// a PYImageView is a child class of UIImageView.
//  placehold: NSString object, an image name, load by PYResource
//  imageUrl: NSString object, if set [image], then the imageUrl will be ignore.
@interface PYImageView (AttributeLoader)
+ (void)rendView:(PYImageView *)imageView withOption:(NSDictionary *)option;
@end

// @littlepush
// littlepush@gmail.com
// PYLab
