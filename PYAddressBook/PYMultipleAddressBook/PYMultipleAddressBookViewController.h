//
//  PYMultipleAddressBookViewController.h
//  PYAddressBook
//
//  Created by littlepush on 9/19/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@protocol PYMultipleAddressBookDelegate;

#define kContactName		@"kContactName"
#define kContactNickname	@"kContactNickname"
#define kContactMobile		@"kContactMobile"
#define kContactEmail		@"kContactEmail"
#define kContactAllMobile	@"kContactAllMobile"

@interface PYMultipleAddressBookViewController : UIViewController
	< UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate >
{
	UISearchBar					*contactSearchBar;
	UITableView					*contactTableView;
	
	NSMutableDictionary			*addressBook;
	NSArray						*addressKeys;
	NSMutableArray				*searchedAddress;
	
	BOOL						isSearching;
}

@property (nonatomic, retain)	id <PYMultipleAddressBookDelegate>	delegate;

-(void) finishPickupContacts;

@end


@protocol PYMultipleAddressBookDelegate <NSObject>

-(void) pyMultiAddressBook:(PYMultipleAddressBookViewController *)addressBook finishPickup:(NSArray *)contacts;
-(void) pyMultiAddressBook:(PYMultipleAddressBookViewController *)addressBook didSelectContact:(NSDictionary *)info;
@end
