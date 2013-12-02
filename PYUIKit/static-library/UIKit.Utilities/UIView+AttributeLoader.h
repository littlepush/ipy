//
//  UIView+AttributeLoader.h
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

#import <UIKit/UIKit.h>

@interface UIFont (AttributeLoader)

// Font options:
// name: NSString object, the font name
// size: float object, the font size
// bold: bool object, if bold the font.
+ (UIFont *)fontWithOption:(NSDictionary *)option;

@end

// Attribute support by UIView
//  frame: NSString object, a CGRect string, {{x, y}, {w, h}}
//  backgroundColor: NSString object, a UIColor option string, see UIColor+PYUIKit for the definition.
//  border: NSDictionary object, includes:
//      borderWidth: float object
//      borderColor: NSString object, a UIColor option string
//  cornerRadius: float object
//  shadow: NSDictionary object, includes:
//      offset: NSString object, a CGSize string, {w, h}
//      color: NSString object, a UIColor option string
//      opacity: float object
//      radius: float object
//      disable-path: bool object
//  clipsToBounds: BOOL object
@interface UIView (AttributeLoader)

// Rend the view with specified option.
+ (void)rendView:(UIView *)view withOption:(NSDictionary *)option;

@end

// Rend a layer with option, the attributes supported are the
// same as UIView.
// masksToBounds: Bool object
@interface CALayer (AttributeLoader)

+ (void)rendLayer:(CALayer *)layer withOption:(NSDictionary *)option;

@end

// Attribute support by UILabel
//  text: NSString object
//  textColor: NSString object, a UIColor option string
//  font: NSDictionary object, a font info dictionary
//  alignment: NSString object, "left", "center", "right"
//  breakMode: NSString object, "head", "middle", "tail", "none"
@interface UILabel (AttributeLoader)

// Rend the label with specified option.
+ (void)rendView:(UILabel *)label withOption:(NSDictionary *)option;

@end

// Attribute support by UIButton
// A button has 4 different states: normal, highlighted, selected, disable
// the attributes of different state should be set in different dictionary.
// for each state, support following attributes:
//  backgroundImage: NSString object, the background image name, use PYResource to load
//  image: NSString object, the front-image name, use PYResource to load
//  title: NSString object, display title string
//  titleColor: NSString object, title color, a UIColor option string
@interface UIButton (AttributeLoader)

+ (void)rendView:(UIButton *)button withOption:(NSDictionary *)option;

@end

// Attribute support by UIImageView
//  image: NSString object, the image to display, use PYResource to load.
@interface UIImageView (AttributeLoader)

+ (void)rendView:(UIImageView *)imageView withOption:(NSDictionary *)option;

@end

// Attribute support by UITableViewCell
@interface UITableViewCell (AttributeLoader)

// Rend the cell with specified option.
//  selectionStyle: NSString object, [none/blue/gray/default]
+ (void)rendView:(UITableViewCell *)cell withOption:(NSDictionary *)option;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
