//
//  PYSlideView+Internal.h
//  pyutility-uitest
//
//  Created by Push Chen on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PYSlideView.h"
#import	"PYSlideContentView.h"

@interface PYSlideViewCell( Internal )

-(void) setCellIndex:(NSUInteger)anIndex;
-(void) setSlideView:(PYSlideView *)aSlideView;
-(void) setRespondedForSelection:(BOOL)aValue;
-(void) _tapGestureAction;

@end


@interface PYSlideView (ContentExchange)
-(void) exchangeMasterContentView:(PYSlideContentView *)master 
	withSliverView:(PYSlideContentView *)sliver;

@end
