//
//  PYMultipleAddressBookViewController.m
//  PYAddressBook
//
//  Created by littlepush on 9/19/12.
//  Copyright (c) 2012 PushLab. All rights reserved.
//

#import "PYMultipleAddressBookViewController.h"
#import "pinyin.h"

NSString *_checkImgData = @"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABsAAAApCAYAAADEZlLzAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAplJREFUeNq0mM9LFGEYx2dnK5LIe/9A/0G38CB68CBhSD+gIBGivQh2EqKFIowQqYNQWhSIZCxGJkaiUFgd6lQX6Siegy56MXZ2/X6n543Ht5md2Z33feHlndn3mfm8n+ed993ZLS2vfw6KlHP9ZzNj3m586UHcpzDwXAC63Ww2N9mGnkHdaO7W63WeVnyb3Wg0Gub4VOjR6iSaBwq269NslCDMVxCGMeZN6MnqBJqHxkpgi77MrhmrUqkUV5QPoQerLjQzllUV6+yPD7OrxopFrJZisGOr42hmjZWkcA1WP53DbCtJ4YLpDB1bzWkrgb13DkO5nDBXM0jhb6cwWB1D81ztFv/Wlo5zZXbRthKzb05hsDqKZj7BagwpjFybDWsrNV8rdmBRWBn1pW0FWA1WO65h52mkrSSF80nBRWDMVS2KokPpkxRuuoYN2VYCmkQK99Jg3KVvova1CatoK5XCV2kXsLeCCZ7GCDdwPJETNIj4PttKzLZaweIIGeV91DMFrEaQwkYr2CwDOUq5QSUDNIDYAW2lYO9aXcgITma1XC4HXC+oIzi/1cpKrysFegqrX1kwlidyQSA3uofakxDfD6PBFNhCVu4NjCOazJHO/6zUg/E1L4zlmbZDvYTDO6q/FwMZSrGa4AtNO7BtjHDOAGmHm1f5QyXNSi3kWp71Yu8gjw1MLYdlvgcCPJxkBdhrWG13AvvBiw3QzB/aF/a6UlaLebecpL3xkB1t+JPHXlfqhWa9COyjesLSt/y//VNI4W4RGCfmgrZLvDBj023nK2ZFJj/VSvq+u4Dto15Ps5PPr/AZcgGLU5Rkx886SWEWjBM/zg3aQNnyHIX/R0Ttwo5k9D8CZAsA7pOnUVe5NFB3OnmPOBBgAFY+P6Nxr4fMAAAAAElFTkSuQmCC";
UIImage *_checkImage = nil;

/* Internal Object */
@interface PYContact : NSObject

@property (nonatomic, copy)		NSString		*name;
@property (nonatomic, copy)		NSString		*nickname;
@property (nonatomic, copy)		NSString		*mobile;
@property (nonatomic, copy)		NSString		*email;

@property (nonatomic, retain)	NSMutableArray	*allMobiles;

-(NSDictionary *) objectToDictionary;

@end

@implementation PYContact
@synthesize name, nickname, mobile, email, allMobiles;
-(void) dealloc {
	self.name = nil;
	self.nickname = nil;
	self.mobile = nil;
	self.email = nil;
	self.allMobiles = nil;
	
	[super dealloc];
}
-(NSDictionary *) objectToDictionary {
	NSDictionary *_dict = [NSDictionary dictionaryWithObjectsAndKeys:
		self.name,			kContactName,
		self.nickname,		kContactNickname,
		self.mobile,		kContactMobile,
		self.email,			kContactEmail,
		self.allMobiles,	kContactAllMobile,
		nil];
	return _dict;
}
@end

/* Contact Cell */
@interface ContactCell : UITableViewCell
{
	UIImageView				*_checkedImage;
}
@end

@implementation ContactCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if ( !self ) return self;
	
	_checkedImage = [[UIImageView object] retain];
	[_checkedImage setImage:_checkImage];
	[_checkedImage setAlpha:0.f];
	[self addSubview:_checkedImage];
	return self;
}

-(void) dealloc
{
	[_checkedImage release];
	[super dealloc];
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	if ( selected ) {
		if ( animated ) {
			[UIView animateWithDuration:.5f animations:^{
				[_checkedImage setAlpha:1.f];
			}];
		} else {
			[_checkedImage setAlpha:1.f];
		}
	} else {
		if ( animated ) {
			[UIView animateWithDuration:.5f animations:^{
				[_checkedImage setAlpha:0.f];
			}];
		} else {
			[_checkedImage setAlpha:0.f];
		}
	}
}

-(void) layoutSubviews
{
	[super layoutSubviews];
	
	[_checkedImage setFrame:CGRectMake(self.bounds.size.width - 58,	
		(self.bounds.size.height - 20) / 2, 14, 20)];
}

@end

@interface PYMultipleAddressBookViewController ()

@end

@implementation PYMultipleAddressBookViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.view setAutoresizesSubviews:YES];
	
	contactTableView = [[[UITableView alloc] initWithFrame:self.view.bounds 
		style:UITableViewStylePlain] retain];
	[contactTableView setAutoresizingMask:
		(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	[self.view addSubview:contactTableView];
	[contactTableView setAllowsMultipleSelection:YES];

	// Add Search Bar
	contactSearchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)] retain];
	contactSearchBar.barStyle = UIBarStyleDefault;
	contactSearchBar.showsCancelButton = YES;
	contactSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	contactSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	contactSearchBar.delegate = self;
	contactTableView.tableHeaderView = contactSearchBar;
	
	// Load address book
	ABAddressBookRef sourceAddressBook = ABAddressBookCreate(); 
	CFArrayRef addressResult = ABAddressBookCopyArrayOfAllPeople( sourceAddressBook );
	//addressBook = [[NSMutableArray array] retain];
	addressBook = [[NSMutableDictionary dictionary] retain];
	int _count = CFArrayGetCount(addressResult);
	
	for ( int i = 0; i < _count; ++i )
	{
		PYContact *contact = [PYContact object];
		ABRecordRef person = CFArrayGetValueAtIndex(addressResult, i);
		
		// Get name
		NSString *_lastname = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
		NSString *_firstname = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		if ( [_lastname length] == 0 ) _lastname = @"";
		if ( [_firstname length] == 0 ) _firstname = @"";
		contact.name = [_lastname stringByAppendingString:_firstname];
		
		// Get nickname
		contact.nickname = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonNicknameProperty);
		if ( [contact.nickname length] == 0 ) contact.nickname = @"";
		
		// Get email
		ABMultiValueRef mails = ABRecordCopyValue(person, kABPersonEmailProperty);
		if ( ABMultiValueGetCount(mails) > 0 ) {
			contact.email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(mails, 0);
		} else {
			contact.email = @"";
		}
		
		// Get mobiles
		contact.allMobiles = [NSMutableArray array];
		ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
		int _telCount = ABMultiValueGetCount(phones);
		for ( int t = 0; t < _telCount; ++t ) {
			NSString *_phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, t);
			[contact.allMobiles addObject:[_phone reformTelphone]];
		}
		
		//[addressBook addObject:contact];
		if ( [contact.name length] == 0 ) {
			if ( [contact.allMobiles count] > 0 ) {
				contact.name = [contact.allMobiles objectAtIndex:0];
			} else if ( [contact.email length] > 0 ) {
				contact.name = contact.email;
			} else {
				continue;
			}
		}
		
		NSString *_firstAlpha = firstAlphabetForWord(contact.name);
		NSMutableArray *_addressArray = [addressBook objectForKey:_firstAlpha];
		if ( _addressArray == nil ) {
			_addressArray = [NSMutableArray array];
			[addressBook setValue:_addressArray forKey:_firstAlpha];
		}
		[_addressArray addObject:contact];
	}
	
	// Sort the address
	NSArray *_keys = [[addressBook keyEnumerator] allObjects];
	addressKeys = [[_keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
		NSString *_sobj1 = (NSString *)obj1;
		NSString *_sobj2 = (NSString *)obj2;
		return [_sobj1 compare:_sobj2];
	}] retain];
	
	CFRelease(addressResult);
	CFRelease(sourceAddressBook);
	
	searchedAddress = [[NSMutableArray array] retain];
	NSURL *_imgUrl = [NSURL URLWithString:_checkImgData];
	NSData *_imgData = [NSData dataWithContentsOfURL:_imgUrl];
	_checkImage = [[UIImage imageWithData:_imgData] retain];
		
	contactTableView.delegate = self;
	contactTableView.dataSource = self;
	[contactTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) finishPickupContacts
{
	NSArray * _selectedRows = [contactTableView indexPathsForSelectedRows];
	NSMutableArray *selectedContact = [NSMutableArray array];
	if ( isSearching ) {
		for ( NSIndexPath *indexPath in _selectedRows ) {
			PYContact *_contact = [searchedAddress objectAtIndex:indexPath.row];
			[selectedContact addObject:[_contact objectToDictionary]];
		}
	} else {
		for ( NSIndexPath *indexPath in _selectedRows ) {
			PYContact *_contact = [(NSMutableArray *)[addressBook 
				objectForKey:[addressKeys objectAtIndex:indexPath.section]] 
					objectAtIndex:indexPath.row];
			[selectedContact addObject:[_contact objectToDictionary]];
		}
	}
	
	if ( [self.delegate respondsToSelector:@selector(pyMultiAddressBook:finishPickup:)] ) {
		[self.delegate pyMultiAddressBook:self finishPickup:selectedContact];
	}
}

#pragma TableView Delegate
-(NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if ( isSearching ) return nil;
	return addressKeys;
}
-(int) numberOfSectionsInTableView:(UITableView *)tableView
{
	if ( isSearching ) return 1;
	return [addressKeys count];
}

-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( isSearching ) return [searchedAddress count];
	return [(NSMutableArray *)[addressBook objectForKey:[addressKeys objectAtIndex:section]] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( isSearching ) return @"";
	return [addressKeys objectAtIndex:section];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *_identify = @"kContactCell";
	ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:_identify];
	if ( contactCell == nil ) {
		contactCell = [[[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault 
			reuseIdentifier:_identify] autorelease];
	}
	if ( !isSearching ) {
		PYContact *_contact = [(NSMutableArray *)[addressBook 
			objectForKey:[addressKeys objectAtIndex:indexPath.section]] 
				objectAtIndex:indexPath.row];
		[contactCell.textLabel setText:_contact.name];
	} else {
		PYContact *_contact = [searchedAddress objectAtIndex:indexPath.row];
		[contactCell.textLabel setText:_contact.name];
	}
	[contactCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return contactCell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *_cell = [tableView cellForRowAtIndexPath:indexPath];
	if ( !_cell.isSelected ) return;
	PYContact *_contact = nil;
	if ( isSearching ) {
		_contact = [searchedAddress objectAtIndex:indexPath.row];
	} else {
		_contact = [(NSMutableArray *)[addressBook objectForKey:[addressKeys 
			objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	}
	if ( [self.delegate respondsToSelector:@selector(pyMultiAddressBook:didSelectContact:)] ) {
		[self.delegate pyMultiAddressBook:self didSelectContact:[_contact objectToDictionary]];
	}
}

#pragma SearchBar Delegate

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	isSearching = NO;
	[contactSearchBar resignFirstResponder];
	[contactTableView reloadData];
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[searchedAddress removeAllObjects];
	if ( [searchText length] > 0 ) {
		isSearching = YES;
		NSString *_firstAlpha = firstAlphabetForWord(searchText);
		NSMutableArray *_contacts = [addressBook objectForKey:_firstAlpha];
		for ( PYContact *contact in _contacts ) {
			NSRange _searchRange = [contact.name rangeOfString:searchText];
			if ( _searchRange.location == NSNotFound ) continue;
			[searchedAddress addObject:contact];
		}
	} else {
		isSearching = NO;
	}
	
	[contactTableView reloadData];
}

@end
