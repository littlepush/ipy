//
//  PYCalendar.m
//  PYUIKit
//
//  Created by Push Chen on 7/27/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYCalendar.h"
#import "PYLibImage.h"

typedef struct {
	NSUInteger		year;
	NSUInteger		month;
} PYCalendarSet;

/*
	PYCalendar Internal Interface
	The internal interface includes: cache processing, 
		date changing, date calculating, layout subviews

 */
@interface PYCalendar()

/* Load cell from datasource or craete default cell. */
-(PYCalendarDateCell *) getCellAtDate:(PYCalendarDate)date;
/* Put a cell to cache for reusing */
-(void) enqueueDateCell:(PYCalendarDateCell *)cell;
/* Show all data in the view. include year-month view, week day description, and day cells. */
-(void) showDateOfCurrentSettingYearMonth;

/* check the input year-month is the previous month of current month */
-(BOOL) isLastMonth:(NSUInteger)month ofYear:(NSUInteger)year;
/* check the input year-month is the next month of current month */
-(BOOL) isNextMonth:(NSUInteger)month ofYear:(NSUInteger)year;

/* get the previous month's info */
-(PYCalendarSet) lastSetInfo;
/* get the next month's info*/
-(PYCalendarSet) nextSetInfo;

/* layout subviews according to different setting */
-(void) layoutWithoutYearMonthView;
-(void) layoutWithoutWeekDesp;
-(void) layoutWithBothExtraInfo;
-(void) layoutWithoutBothExtraInfo;

/* core layout messages */
-(void) layoutWithYearMonthViewHeight:(CGFloat)ymHeight;
-(void) layoutWithWeekDespHeight:(CGFloat)wdspHeight;
-(void) layoutDateCellsInRect:(CGRect)rect;

/* day cell click action */
-(void) dayCellDidSelectedAction:(id)sender;

/* week day desp cell click action */
-(void) weekdayDespCellDidSelectedAction:(id)sender;

@end

/*
	PYCalendarDateCell Internal Interface
	Process the internal data.
 */
@interface PYCalendarDateCell()

// set the date information
-(void) setDateInformation:(PYCalendarDate)dateInfo;

// set the calendar information
-(void) setCalendar:(PYCalendar *)calendar;

@end

/*
	PYCalendarYearMonthView Internal Interface
 */
@interface PYCalendarYearMonthView()

// set the calendar information
-(void) setCalendar:(PYCalendar *)calendar;

/* Gesture Action Delegate */
-(void) swipeLeftGestureAction:(UISwipeGestureRecognizer *)gesture;
-(void) swipeRightGestureAction:(UISwipeGestureRecognizer *)gesture;

/* Button Switch Month Actions */
-(void) prevMonthButtonAction:(id)sender;
-(void) prevYearButtonAction:(id)sender;
-(void) nextMonthButtonAction:(id)sender;
-(void) nextYearButtonAction:(id)sender;

@end

/* PYCalendarWeekDescriptCell Internal Interface */
@interface PYCalendarWeekDescriptCell()

/* set the day of week id */
-(void) setWeekday:(PYWeekDay)weekdayId;

/* set the calendar information */
-(void) setCalendar:(PYCalendar *)calendar;

@end

/* Calendar Implementation */
@implementation PYCalendar

@synthesize currentYear = _currentYear;
@synthesize currentMonth = _currentMonth;

@dynamic showWeekdayName;
-(BOOL) showWeekdayName { return _showWeekdayName; }
-(void) setShowWeekdayName:(BOOL)isShow
{
	_showWeekdayName = isShow;
	[self setNeedsLayout];
}

@dynamic showYearMonthView;
-(BOOL) showYearMonthView { return _showYearMonthView; }
-(void) setShowYearMonthView:(BOOL)isShow
{
	_showYearMonthView = isShow;
	[self setNeedsLayout];
}

@dynamic backgroundImageView;
-(UIImageView *)backgroundImageView { return _backgroundImageView; }
-(void) setBackgroundImageView:(UIImageView *)anImageView
{
	if ( _backgroundImageView != nil ) {
		[_backgroundImageView removeFromSuperview];
		[_backgroundImageView release];
	}
	_backgroundImageView = [anImageView retain];
	[self insertSubview:_backgroundImageView atIndex:0];
	[self setNeedsLayout];
}

@synthesize yearMonthView = _yearMonthView;

@synthesize delegate = _delegate;
@dynamic datasource;
-(id< PYCalendarDataSource >) datasource {
	return _datasource;
}
-(void) setDatasource:(id<PYCalendarDataSource>)ds
{
	_datasource = nil;
	_datasource = [ds retain];
	[self showDateOfCurrentSettingYearMonth];
}

+(PYWeekDay)firstDayInWeekOfYear:(NSUInteger)year month:(NSUInteger)month
{
	NSCalendar *calendar = [[[NSCalendar alloc] 
		initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSCalendarUnit _unit = NSWeekdayCalendarUnit;
	
	NSDateFormatter *_format = [[[NSDateFormatter alloc] init] autorelease];
	[_format setDateFormat:@"yyyy-MM-dd"];
	NSDate *_firstDay = [_format dateFromString:
		[NSString stringWithFormat:@"%04d-%02d-01", year, month]];
	
	NSDateComponents *_dateComponents = [calendar components:_unit fromDate:_firstDay];
	//PYLog(@"%d", [_dateComponents weekday]);
	return PYWeekDayConvert([_dateComponents weekday]);
}

+(NSUInteger) daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
	static NSUInteger _daysInMonth[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
	NSUInteger _days = _daysInMonth[month - 1];
	if ( month == 2 && (
		(year % 100 == 0 && year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)
	) ) _days += 1;
	return _days;
}

-(void) internalInitial
{
	[super internalInitial];
	
	[self setBackgroundColor:[UIColor clearColor]];
	NSCalendar *_cal = [[[NSCalendar alloc]
		initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSCalendarUnit _unit = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *_com = [_cal components:_unit fromDate:[NSDate date]];
	
	_todayYear = _currentYear = [_com year];
	_todayMonth = _currentMonth = [_com month];
	_todayDay = _currentDay = [_com day];
	
	_showCacheDay = YES;
	_showWeekdayName = YES;
	_showYearMonthView = YES;

	//[self showDateOfCurrentSettingYearMonth];
}

-(void) willMoveToSuperview:(UIView *)newSuperview
{
	if ( newSuperview != nil ) {
		[self showDateOfCurrentSettingYearMonth];
	}
}

-(void) dealloc
{
	for ( int i = 0; i < PYCalendarWeeksInMonth; ++i ) {
		for ( int j = 0; j < PYCalendarDaysInWeek; ++j ) {
			[_dateItemMatrix[i][j] release];
		}
	}
	
	for ( int i = 0; i < PYCalendarDaysInWeek; ++i ) {
		[_dayInWeekName[i] release];
	}
	
	[_yearMonthView release];
	
	[super dealloc];
}

-(BOOL) isLastMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
	if ( month == 12 && year == (_currentYear - 1) 
		&& _currentMonth == 1 ) return YES;
	if ( month == (_currentMonth - 1) 
		&& year == _currentYear ) return YES;
	return NO;
}
-(BOOL) isNextMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
	if ( month == 1 && year == (_currentYear + 1) 
		&& _currentMonth == 12 ) return YES;
	if ( month == (_currentMonth + 1) 
		&& year == _currentYear ) return YES;
	return NO;
}

-(PYCalendarSet) lastSetInfo 
{
	return (PYCalendarSet){
		(_currentMonth == 1 ? _currentYear - 1 : _currentYear),
		(_currentMonth == 1 ? 12 : _currentMonth - 1)
	};
}

-(PYCalendarSet) nextSetInfo
{
	return (PYCalendarSet){
		(_currentMonth == 12 ? _currentYear + 1 : _currentYear),
		(_currentMonth == 12 ? 1 : _currentMonth + 1)
	};
}

/* day cell click action */
-(void) dayCellDidSelectedAction:(id)sender
{
	if ( [_delegate respondsToSelector:@selector(pyCalendar:didSelectedDate:)] ) {
		PYCalendarDateCell *_cell = (PYCalendarDateCell *)sender;
		[_delegate pyCalendar:self didSelectedDate:_cell.dateInfo];
	}
}

/* week day desp cell click action */
-(void) weekdayDespCellDidSelectedAction:(id)sender {
	if ( [_delegate respondsToSelector:@selector(pyCalendar:selectedWeekdayID:)] ) {
		PYCalendarWeekDescriptCell *_cell = (PYCalendarWeekDescriptCell *)sender;
		[_delegate pyCalendar:self selectedWeekdayID:_cell.weekdayId];
	}
}

-(PYCalendarDateCell *)getCellAtDate:(PYCalendarDate)date
{
	BOOL isPrevMonth = [self isLastMonth:date.month ofYear:date.year];
	BOOL isNextMonth = [self isNextMonth:date.month ofYear:date.year];
	NSUInteger _daysInMonth = [PYCalendar 
		daysInMonth:_currentMonth ofYear:_currentYear];
	NSUInteger _bufferDay = (_firstDayOfMonth + _daysInMonth);
	
	NSUInteger week = ( isPrevMonth ? 0 : (
		isNextMonth ? ((_bufferDay + date.day - 1) / PYCalendarDaysInWeek) :
			(date.day + _firstDayOfMonth - 1) / PYCalendarDaysInWeek
	) );

	// clear the last cell
	PYCalendarDateCell *_cell = _dateItemMatrix[week][date.weekdayId];
	if ( _cell != nil ) {
		[self enqueueDateCell:_cell];
		_dateItemMatrix[week][date.weekdayId] = nil;
	}
	
	if ( [_datasource respondsToSelector:@selector(pyCalendar:dateCellOfDate:)] )
	{
		_cell = [_datasource pyCalendar:self 
			dateCellOfDate:date];
	}
	
	if ( _cell == nil ) {
		_cell = [[[PYCalendarDateCell alloc] 
			initDateCellWithType: (PYCalendarIsWeekday(date.weekdayId) ?
									PYCalendarDateCellTypeWeekday : 
									PYCalendarDateCellTypeWeekend) 
			reusableIdentify:PYCalendarDateCellIdentify] autorelease];
	}
		
	[_cell setDateInformation:date];
	_dateItemMatrix[week][date.weekdayId] = [_cell retain];
	
	[_cell setCalendar:self];
	[_cell addTarget:self action:@selector(dayCellDidSelectedAction:) 
		forControlEvents:UIControlEventTouchUpInside];
		
	[self addSubview:_cell];
	return _cell;
}

-(void) showDateOfCurrentSettingYearMonth
{
	if ( _showYearMonthView ) {
		if ( _yearMonthView == nil ) {
			if ( [_datasource respondsToSelector:@selector(pyCalendarYearMonthView:)] )
				_yearMonthView = [[_datasource pyCalendarYearMonthView:self] retain];
			if ( _yearMonthView == nil ) {
				_yearMonthView = [[[PYCalendarYearMonthView alloc] init] retain];
			}
			[_yearMonthView setCalendar:self];
			[self addSubview:_yearMonthView];
		}
		[_yearMonthView setYear:_currentYear month:_currentMonth];
	}
	
	if ( _showWeekdayName ) {
		for ( PYWeekDay d = PYWeekDaySun; d <= PYWeekDaySat; ++d) {
			PYCalendarWeekDescriptCell *_cell = nil;
			if ( [_datasource respondsToSelector:@selector(pyCalendar:weekdayId:)] ) {
				_cell = [_datasource pyCalendar:self weekdayId:d];
			}
			
			if ( _cell == nil ) {
				_cell = [[[PYCalendarWeekDescriptCell alloc] init] autorelease];
			}
			
			[_cell setCalendar:self];
			[_cell setWeekday:d];
			[_cell addTarget:self action:@selector(weekdayDespCellDidSelectedAction:) 
				forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_cell];
			_dayInWeekName[d] = [_cell retain];
		}
	}
	
	// get first day
	_firstDayOfMonth = [PYCalendar 
		firstDayInWeekOfYear:_currentYear month:_currentMonth];
	NSUInteger _daysInMonth = [PYCalendar daysInMonth:_currentMonth ofYear:_currentYear];
	
	// load current month date
	for ( int i = 0; i < _daysInMonth; ++i ) {
		NSUInteger _dayInPicker = i + _firstDayOfMonth;
		NSUInteger _dayInWeek = _dayInPicker % PYCalendarDaysInWeek;
		PYCalendarDate _dateInfo = {
			_currentYear,
			_currentMonth,
			i + 1,
			_dayInWeek
		};
		PYCalendarDateCell *_cell = [self getCellAtDate:_dateInfo];
		[_cell cellIsCacheDate:NO];
	}	
	
	if ( !_showCacheDay ) {
		// Check the cache cell is empty
		for ( int i = 0; i < _firstDayOfMonth; ++i ) {
			if ( _dateItemMatrix[0][i] != nil ) {
				[self enqueueDateCell:_dateItemMatrix[0][i]];
				_dateItemMatrix[0][i] = nil;
			}
		}
		
		for ( int _lastItem = _firstDayOfMonth + _daysInMonth;
			_lastItem < 42; ++_lastItem )
		{
			NSUInteger _week = _lastItem / PYCalendarDaysInWeek;
			NSUInteger _day = _lastItem % PYCalendarDaysInWeek;
			if ( _dateItemMatrix[_week][_day] != nil ) {
				[self enqueueDateCell:_dateItemMatrix[_week][_day]];
				_dateItemMatrix[_week][_day] = nil;
			}
		}
	}
	else {
		// load cache day
		PYCalendarSet _lastSetInfo = [self lastSetInfo];
		NSUInteger _lastMonthDays = [PYCalendar 
			daysInMonth:_lastSetInfo.month ofYear:_lastSetInfo.year];
		for ( int i = 0; i < _firstDayOfMonth; ++i ) {
			PYCalendarDate _dateInfo = {
				_lastSetInfo.year,
				_lastSetInfo.month,
				_lastMonthDays - i,
				_firstDayOfMonth - i - 1
			};
			PYCalendarDateCell *_cell = [self getCellAtDate:_dateInfo];
			[_cell cellIsCacheDate:YES];
		}
		
		NSUInteger _lastItem = _firstDayOfMonth + _daysInMonth;
		PYCalendarSet _nextSetInfo = [self nextSetInfo];
		for ( int i = 1; _lastItem < 42; ++_lastItem, ++i ) {
			PYCalendarDate _dateInfo = {
				_nextSetInfo.year,
				_nextSetInfo.month,
				i,
				(_lastItem % 7)
			};
			PYCalendarDateCell *_cell = [self getCellAtDate:_dateInfo];
			[_cell cellIsCacheDate:YES];
		}
	}
	
	[self setNeedsLayout];
	if ( [_delegate respondsToSelector:@selector(pyCalendar:changeToDate:)] )
	{
		PYCalendarDate _dateInfo = { _currentYear, _currentMonth, 0, 0 };
		[_delegate pyCalendar:self changeToDate:_dateInfo];
	}
}

-(void) layoutWithYearMonthViewHeight:(CGFloat)ymHeight
{
	CGRect _ymFrame = CGRectMake(0, 0, self.bounds.size.width, ymHeight);
	CGRect _dcFrame = CGRectMake(0, ymHeight, 
		self.bounds.size.width, self.bounds.size.height - ymHeight);
	[_yearMonthView setFrame:_ymFrame];
	[self layoutDateCellsInRect:_dcFrame];
}

-(void) layoutWithWeekDespHeight:(CGFloat)wdspHeight
{
	//CGRect _wdspFrame = CGRectMake(0, 0, self.bounds.size.width, _wdspHeight);
	CGRect _dcFrame = CGRectMake(0, wdspHeight, self.bounds.size.width, 
		self.bounds.size.height - wdspHeight);
	
	CGFloat _width = self.bounds.size.width / PYCalendarDaysInWeek;
	for ( int i = 0; i < PYCalendarDaysInWeek; ++i ) {
		CGRect _wdspFrame = CGRectMake(i * _width, 0, _width, wdspHeight);
		[_dayInWeekName[i] setFrame:_wdspFrame];
	}
	[self layoutDateCellsInRect:_dcFrame];
}

-(void) layoutWithoutYearMonthView
{
	CGFloat _wdspHeight = 0.f;
	if ( [_datasource respondsToSelector:@selector(pyCalendarWeekdayDescripitionHeight:)] ) {
		_wdspHeight = [_datasource pyCalendarWeekdayDescripitionHeight:self];
		if ( _wdspHeight <= 0.f ) {
			[self layoutWithoutBothExtraInfo];
			return;
		}
	} else {
		_wdspHeight = (self.bounds.size.height / (PYCalendarWeeksInMonth + 0.5)) * 0.5f;
	}
	[self layoutWithWeekDespHeight:_wdspHeight];
}

-(void) layoutWithoutWeekDesp
{
	CGFloat _ymHeight = 0.f;
	if ( [_datasource respondsToSelector:@selector(pyCalendarYearMonthViewHeight:)] ) {
		_ymHeight = [_datasource pyCalendarYearMonthViewHeight:self];
		
		// No Year Month View
		if ( _ymHeight <= 0.f ) {
			[self layoutWithoutBothExtraInfo];
			return;
		}
	} else {
		_ymHeight = (self.bounds.size.height / ( PYCalendarWeeksInMonth + 1.5)) * 1.5f;
	}
	
	[self layoutWithYearMonthViewHeight:_ymHeight];
}

-(void) layoutWithBothExtraInfo
{
	CGFloat _ymHeight = 0.f;
	CGFloat _wdspHeight = 0.f;
	CGFloat _parts = PYCalendarWeeksInMonth;
	
	// Check year-month view
	if ( [_datasource respondsToSelector:@selector(pyCalendarYearMonthViewHeight:)] )
	{
		_ymHeight = [_datasource pyCalendarYearMonthViewHeight:self];
		if ( _ymHeight <= 0.f ) {
			[self layoutWithoutYearMonthView];
			return;
		}
	} else {
		_parts += 1.5f;
	}
	
	// check week day description
	if ( [_datasource respondsToSelector:@selector(pyCalendarWeekdayDescripitionHeight:)] )
	{
		_wdspHeight = [_datasource pyCalendarWeekdayDescripitionHeight:self];
		if ( _wdspHeight <= 0.f ) {
			if ( _ymHeight > 0.f ) {
				[self layoutWithYearMonthViewHeight:_ymHeight];
				return;
			} else {
				[self layoutWithoutBothExtraInfo];
				return;
			}
		}
	} else {
		_parts += 0.5f;
	}
	
	CGFloat _height = (self.bounds.size.height - _ymHeight - _wdspHeight) / _parts;
	if ( _ymHeight == 0.f ) _ymHeight = (_height * 1.5f);
	if ( _wdspHeight == 0.f ) _wdspHeight = (_height * 0.5f);
	
	CGRect _ymFrame = CGRectMake(0, 0, self.bounds.size.width, _ymHeight);
	CGRect _wdspFrame = CGRectMake(0, _ymHeight, self.bounds.size.width, _wdspHeight);
	CGRect _dcFrame = CGRectMake(0, _ymHeight + _wdspHeight, self.bounds.size.width, 
		(self.bounds.size.height - _ymHeight - _wdspHeight));
		
	[_yearMonthView setFrame:_ymFrame];
	
	CGFloat _width = self.bounds.size.width / PYCalendarDaysInWeek;
	for ( int i = 0; i < PYCalendarDaysInWeek; ++i ) {
		CGRect _dspFrame = _wdspFrame;
		_dspFrame.origin.x = i * _width;
		_dspFrame.size.width = _width;
		[_dayInWeekName[i] setFrame:_dspFrame];
	}
	
	[self layoutDateCellsInRect:_dcFrame];
}
-(void) layoutWithoutBothExtraInfo
{
	[self layoutDateCellsInRect:self.bounds];
}
-(void) layoutDateCellsInRect:(CGRect)rect
{
	CGFloat _width = rect.size.width / PYCalendarDaysInWeek;
	CGFloat _height = rect.size.height / PYCalendarWeeksInMonth;
	
	for ( int week = 0; week < PYCalendarWeeksInMonth; ++week )
	{
		for ( PYWeekDay day = PYWeekDaySun; day <= PYWeekDaySat; ++day )
		{
			if ( _dateItemMatrix[week][day] == nil ) continue;
			CGRect _cellFrame = CGRectMake(
				rect.origin.x + day * _width, 
				rect.origin.y + week * _height, 
				_width, _height);
			[_dateItemMatrix[week][day] setFrame:_cellFrame];
		}
	}
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;

	if ( _showYearMonthView == YES && _showWeekdayName == YES )
		[self layoutWithBothExtraInfo];
	else if ( _showYearMonthView == YES && _showWeekdayName == NO )
		[self layoutWithoutWeekDesp];
	else if ( _showYearMonthView == NO && _showWeekdayName == YES )
		[self layoutWithoutYearMonthView];
	else
		[self layoutWithoutBothExtraInfo];
}

-(void) reloadData 
{
	[self showDateOfCurrentSettingYearMonth];
}

-(void) gotoToday 
{
	_currentDay = _todayDay;
	_currentMonth = _todayMonth;
	_currentYear = _todayYear;
	[self showDateOfCurrentSettingYearMonth];
}

-(void) gotoPreviousMonth 
{
	PYCalendarSet _prevSet = [self lastSetInfo];
	_currentYear = _prevSet.year;
	_currentMonth = _prevSet.month;
	[self showDateOfCurrentSettingYearMonth];
}

-(void) gotoNextMonth 
{
	PYCalendarSet _nextSet = [self nextSetInfo];
	_currentYear = _nextSet.year;
	_currentMonth = _nextSet.month;
	[self showDateOfCurrentSettingYearMonth];
}

-(void) gotoPreviousYear 
{
	_currentYear -= 1;
	[self showDateOfCurrentSettingYearMonth];
}

-(void) gotoNextYear 
{
	_currentYear += 1;
	[self showDateOfCurrentSettingYearMonth];
}

-(PYCalendarDateCell *) cellOfDay:(NSUInteger)day 
{
	NSUInteger _theSelectedDay = _firstDayOfMonth + day - 1;
	NSUInteger _theSelectedWeek = _theSelectedDay / PYCalendarDaysInWeek;
	NSUInteger _theSelectedWeekDay = _theSelectedDay % PYCalendarDaysInWeek;
	return _dateItemMatrix[_theSelectedWeek][_theSelectedWeekDay];
}

-(NSArray *) cellsOfWeekday 
{
	NSMutableArray *_cells = [NSMutableArray array];
	
	for ( PYWeekDay d = PYWeekDayMon; d < PYWeekDaySat; ++d )
	{
		for ( int w = 0; w < 7; ++w )
		{
			[_cells addObject:_dateItemMatrix[w][d]];
		}
	}	
	return _cells;
}

-(NSArray *) cellsOfWeekend 
{
	NSMutableArray *_cells = [NSMutableArray array];

	for ( int w = 0; w < 7; ++w ) 
	{
		[_cells addObject:_dateItemMatrix[w][PYWeekDaySun]];
		[_cells addObject:_dateItemMatrix[w][PYWeekDaySat]];
	}
	return _cells;
}

-(NSArray *) cellsOfDayAs:(PYWeekDay)wd 
{
	NSMutableArray *_cells = [NSMutableArray array];
	for ( int w = 0; w < 7; ++w ) 
	{
		[_cells addObject:_dateItemMatrix[w][wd]];
	}
	return _cells;
}

-(NSArray *) cellsofWeek:(NSUInteger)weekIndex 
{
	NSMutableArray *_cells = [NSMutableArray array];
	for ( PYWeekDay _d = PYWeekDaySun; _d <= PYWeekDaySat; ++_d )
	{
		[_cells addObject:_dateItemMatrix[weekIndex][_d]];
	}
	return _cells;
}

-(PYCalendarDateCell *) dequeueReusableDateCellForIdentify:(NSString *)identify 
{
	NSMutableSet *_cacheSet = [_dayCellCache objectForKey:identify];
	if ( _cacheSet == nil ) return nil;
	PYCalendarDateCell *_cell = [[[_cacheSet anyObject] retain] autorelease];
	if ( _cell == nil ) return nil;
	[_cacheSet removeObject:_cell];
	
	[_cell prepareForReuse];
	return _cell;
}

-(void) enqueueDateCell:(PYCalendarDateCell *)cell
{
	if ( cell == nil ) return;
	[cell removeFromSuperview];
	
	NSMutableSet *_cacheSet = [_dayCellCache objectForKey:cell.reusableIdentify];
	if ( _cacheSet == nil ) {
		_cacheSet = [NSMutableSet set];
		[_dayCellCache setValue:_cacheSet forKey:cell.reusableIdentify];
	}
	[_cacheSet addObject:cell];
}

@end

/* Calendar Cell Implementation */
@implementation PYCalendarDateCell

@synthesize reusableIdentify = _reusableIdentify;
@synthesize date = _date;
@synthesize selectionStyle = _selectionStyle;
@synthesize dayLabel = _dayLabel;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize calendar = _calendar;

@dynamic year;
-(NSUInteger) year { return _dateInfo.year; }

@dynamic month;
-(NSUInteger) month { return _dateInfo.month; }

@dynamic day;
-(NSUInteger) day { return _dateInfo.day; }

@dynamic dayInWeek;
-(PYWeekDay) dayInWeek { return _dateInfo.weekdayId; }

@synthesize dateInfo = _dateInfo;

@dynamic isWeekDay;
-(BOOL) isWeekDay { return PYCalendarIsWeekday(_dateInfo.weekdayId); }

@dynamic isWeekEnd;
-(BOOL) isWeekEnd { return PYCalendarIsWeekend(_dateInfo.weekdayId); }

-(id) initDateCellWithType:(PYCalendarDateCellType)type 
	reusableIdentify:(NSString *)identify
{
	self = [super init];
	if ( self ) {
		_reusableIdentify = [identify retain];
		_cellType = type;
		
		if ( _backgroundImageView != nil ) {
			UIImage *_bkg = [PYLibImage
				imageForKey:(type == PYCalendarDateCellTypeWeekday ?
					PYLibImageCalendarWeekDay : PYLibImageCalendarWeekEnd)];
			[_backgroundImageView setImage:_bkg];
		}
	}
	return self;
}

-(void) internalInitial
{
	[super internalInitial];
	
	_reusableIdentify = [PYCalendarDateCellIdentify retain];
	_cellType = PYCalendarDateCellTypeWeekday;
	
	if ( ![NSStringFromClass([self class]) isEqualToString:@"PYCalendarDateCell"] )
		return;
	
	// use defautl cell
	_backgroundImageView = [[[UIImageView alloc] init] retain];
	[self addSubview:_backgroundImageView];
	[_backgroundImageView setImage:[PYLibImage imageForKey:PYLibImageCalendarWeekDay]];
	
	_dayLabel = [[[UILabel alloc] init] retain];
	[_dayLabel setBackgroundColor:[UIColor clearColor]];
	[_dayLabel setTextAlignment:UITextAlignmentCenter];
	[_dayLabel setFont:[UIFont systemFontOfSize:14]];
	[self addSubview:_dayLabel];
}

-(void) dealloc
{
	_reusableIdentify = nil;
	_dayLabel = nil;
	_backgroundImageView = nil;
	_theDate = nil;
	_calendar = nil;
	
	[super dealloc];
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	
	if ( _backgroundImageView == nil ) return;
	[_backgroundImageView setFrame:self.bounds];
	[_dayLabel setFrame:self.bounds];
}

-(void) prepareForReuse
{
}

-(void) cellUpdateDateInformation
{
}

-(void) cellIsCacheDate:(BOOL)isCache
{
	if ( _dayLabel == nil ) return;
	if (isCache)
		[_dayLabel setTextColor:[UIColor grayColor]];
	else 
		[_dayLabel setTextColor:[UIColor blackColor]];
}

// set the date information
-(void) setDateInformation:(PYCalendarDate)dateInfo
{
	_dateInfo = dateInfo;
	
	NSDateFormatter *_format = [[[NSDateFormatter alloc] init] autorelease];
	[_format setDateFormat:@"yyyy-MM-dd"];
	NSString *_dateString = [NSString stringWithFormat:@"%4d-%02d-%02d", 
		dateInfo.year, dateInfo.month, dateInfo.day];
	_date = [[_format dateFromString:_dateString] retain];
	
	[self cellUpdateDateInformation];
	
	if ( _dayLabel != nil ) {
		[_dayLabel setText:[NSString stringWithFormat:@"%d", dateInfo.day]];
	}
}

// set the calendar information
-(void) setCalendar:(PYCalendar *)calendar
{
	_calendar = nil;
	_calendar = [calendar retain];
}

@end


/* PYCalendarYearMonthView Implementation */
@implementation PYCalendarYearMonthView

@synthesize calendar = _calendar;
@synthesize isSwipeToChangeMonth = _swipeToChangeMonth;
-(void) setSwipeToChangeMonth:(BOOL)isSwipe
{
	if ( _swipeToChangeMonth == isSwipe ) return;
	_swipeToChangeMonth = isSwipe;
	
	if ( isSwipe ) {
		_swipeLeftGesture = [[[UISwipeGestureRecognizer alloc] 
			initWithTarget:self action:@selector(swipeLeftGestureAction:)] 
				retain];
		[_swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
		[self addGestureRecognizer:_swipeLeftGesture];
		
		_swipeRightGesture = [[[UISwipeGestureRecognizer alloc]
			initWithTarget:self action:@selector(swipeRightGestureAction:)]
				retain];
		[_swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
		[self addGestureRecognizer:_swipeRightGesture];
		
	} else {
		[self removeGestureRecognizer:_swipeLeftGesture];
		[self removeGestureRecognizer:_swipeRightGesture];
		[_swipeLeftGesture release]; _swipeLeftGesture = nil;
		[_swipeRightGesture release]; _swipeRightGesture = nil;
		
	}
	[self setNeedsLayout];
}
@synthesize isShowMonthSwitchButton = _showMonthButton;
-(void) setShowMonthSwitchButton:(BOOL)isShow 
{
	if ( _showMonthButton == isShow ) return;
	_showMonthButton = isShow;
	
	if ( isShow ) {
		_prevMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_prevMonthButton 
			setImage:[PYLibImage imageForKey:PYLibImageCalendarPrevMonth] 
			forState:UIControlStateNormal];
		[_prevMonthButton 
			addTarget:self 
			action:@selector(prevMonthButtonAction:) 
			forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_prevMonthButton];
		
		_nextMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_nextMonthButton
			setImage:[PYLibImage imageForKey:PYLibImageCalendarNextMonth] 
			forState:UIControlStateNormal];
		[_nextMonthButton
			addTarget:self
			action:@selector(nextMonthButtonAction:) 
			forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_nextMonthButton];
	} else {
		[_prevMonthButton removeFromSuperview];
		[_prevMonthButton release];
		_prevMonthButton = nil;
		
		[_nextMonthButton removeFromSuperview];
		[_nextMonthButton release];
		_nextMonthButton = nil;
	}
	[self setNeedsLayout];
}

@synthesize isShowYearSwitchButton = _showYearButton;
-(void) setShowYearSwitchButton:(BOOL)isShow 
{
	if ( _showYearButton == isShow ) return;
	_showYearButton = isShow;
	
	if ( isShow ) {
		_prevYearButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_prevYearButton 
			setImage:[PYLibImage imageForKey:PYLibImageCalendarPrevYear] 
			forState:UIControlStateNormal];
		[_prevYearButton 
			addTarget:self 
			action:@selector(prevYearButtonAction:) 
			forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_prevYearButton];
		
		_nextYearButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[_nextYearButton
			setImage:[PYLibImage imageForKey:PYLibImageCalendarNextYear] 
			forState:UIControlStateNormal];
		[_nextYearButton
			addTarget:self
			action:@selector(nextYearButtonAction:) 
			forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_nextYearButton];
	} else {
		[_prevYearButton removeFromSuperview];
		[_prevYearButton release];
		_prevYearButton = nil;
		
		[_nextYearButton removeFromSuperview];
		[_nextYearButton release];
		_nextYearButton = nil;
	}
	[self setNeedsLayout];
}

@dynamic yearMonthLabel;
-(UILabel *)yearMonthLabel { return _yearMonthLabel; }
-(void) setYearMonthLabel:(UILabel *)aLabel
{
	if ( _yearMonthLabel != nil ) {
		[_yearMonthLabel removeFromSuperview];
		[_yearMonthLabel release];
	}
	_yearMonthLabel = [aLabel retain];
	[self insertSubview:_yearMonthLabel atIndex:0];
	[self setNeedsLayout];
}

-(void) setCalendar:(PYCalendar *)calendar
{
	_calendar = nil;
	_calendar = [calendar retain];
}

-(void) internalInitial
{
	[super internalInitial];
	
	_format = [@"yyyy/MM" retain];
		
	_showYearButton = NO;
	_showMonthButton = NO;
	_swipeToChangeMonth = NO;

	if ( ![NSStringFromClass([self class])
		isEqualToString:@"PYCalendarYearMonthView"] )
		return;	// sub class
	
	[self setShowYearSwitchButton:YES];
	[self setShowMonthSwitchButton:YES];
	[self setSwipeToChangeMonth:YES];
	
	_yearMonthLabel = [[[UILabel alloc] init] retain];
	[_yearMonthLabel setTextAlignment:UITextAlignmentCenter];
	[_yearMonthLabel setBackgroundColor:[UIColor clearColor]];
	[_yearMonthLabel setFont:[UIFont boldSystemFontOfSize:17]];
	[self addSubview:_yearMonthLabel];
}

/* Gesture Action Delegate */
-(void) swipeLeftGestureAction:(UISwipeGestureRecognizer *)gesture
{
	[_calendar gotoNextMonth];
}
-(void) swipeRightGestureAction:(UISwipeGestureRecognizer *)gesture
{
	[_calendar gotoPreviousMonth];
}

/* Button Switch Month Actions */
-(void) prevMonthButtonAction:(id)sender
{
	[_calendar gotoPreviousMonth];
}
-(void) prevYearButtonAction:(id)sender
{
	[_calendar gotoPreviousYear];
}
-(void) nextMonthButtonAction:(id)sender
{
	[_calendar gotoNextMonth];
}
-(void) nextYearButtonAction:(id)sender
{
	[_calendar gotoNextYear];
}

-(void) setYear:(NSUInteger)year month:(NSUInteger)month
{
	_year = year;
	_month = month;
	NSDateFormatter *_df = [[[NSDateFormatter alloc] init] autorelease];
	[_df setDateFormat:@"yyyy-MM-dd"];
	_date = [[_df dateFromString:[NSString 
		stringWithFormat:@"%04d-%02d-01", _year, _month]] 
		retain];
	[self setNeedsLayout];
}

-(void) setFormat:(NSString *)format
{
	_format = [format retain];
	[self setNeedsLayout];
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	
	if ( _yearMonthLabel != nil ) {
		NSDateFormatter *_df = [[[NSDateFormatter alloc] init] autorelease];
		[_df setDateFormat:_format];
		NSString *_ymString = [_df stringFromDate:_date];
		[_yearMonthLabel setText:_ymString];
		[_yearMonthLabel setFrame:self.bounds];
	}
	
	CGFloat _btnWidth = self.bounds.size.width / 10.f;
	CGFloat _y = self.bounds.size.height / 4;
	CGFloat _h = self.bounds.size.height / 2;
	if ( _showYearButton ) {
		CGRect _prevYearFrame = CGRectMake(0, _y, _btnWidth, _h);
		CGRect _nextYearFrame = CGRectMake(
			self.bounds.size.width - _btnWidth, _y, 
			_btnWidth, _h);
		[_prevYearButton setFrame:_prevYearFrame];
		[_nextYearButton setFrame:_nextYearFrame];
	}
	
	if ( _showMonthButton ) {
		CGFloat _leftX = (_showYearButton ? _btnWidth + 2 : 0);
		CGFloat _rightX = (_showYearButton ? self.bounds.size.width - 2 - 2 * _btnWidth : 
			self.bounds.size.width - _btnWidth );
		CGRect _prevMonthFrame = CGRectMake(_leftX, _y, _btnWidth, _h);
		CGRect _nextMonthFrame = CGRectMake(_rightX, _y, _btnWidth, _h);
		
		[_prevMonthButton setFrame:_prevMonthFrame];
		[_nextMonthButton setFrame:_nextMonthFrame];
	}
}

@end


/* PYCalendarWeekDescriptCell Implementation */
@implementation PYCalendarWeekDescriptCell

@synthesize calendar = _calendar;
@synthesize weekdayId = _weekday;

@dynamic weekdayDescriptionLabel;
-(UILabel *)weekdayDescriptionLabel { return _weekdayDescriptionLabel; }
-(void) setWeekdayDescriptionLabel:(UILabel *)aLabel
{
	if ( _weekdayDescriptionLabel != nil ) {
		[_weekdayDescriptionLabel removeFromSuperview];
		[_weekdayDescriptionLabel release];
	}
	_weekdayDescriptionLabel = [aLabel retain];
	[self addSubview:_weekdayDescriptionLabel];
	[self setNeedsLayout];
}

-(void) internalInitial
{
	[super internalInitial];
	
	if ( ![NSStringFromClass([self class]) 
		isEqualToString:@"PYCalendarWeekDescriptCell"] )
		return;	// sub class
	
	_weekdayDescriptionLabel = [[[UILabel alloc] init] retain];
	[_weekdayDescriptionLabel setTextAlignment:UITextAlignmentCenter];
	[_weekdayDescriptionLabel setBackgroundColor:[UIColor clearColor]];
	[_weekdayDescriptionLabel setFont:[UIFont systemFontOfSize:11]];
	[self addSubview:_weekdayDescriptionLabel];
}

-(void) layoutSubviews
{
	PYComponentViewInitChecking;
	
	if ( _weekdayDescriptionLabel != nil ) {
		[_weekdayDescriptionLabel setFrame:self.bounds];
		[_weekdayDescriptionLabel setText:[self descriptionOfWeekdayId]];
	}
}

-(void) setCalendar:(PYCalendar *)calendar
{
	_calendar = nil;
	_calendar = [calendar retain];
}

-(void) setWeekday:(PYWeekDay)weekdayId
{
	_weekday = weekdayId;
}

-(NSString *) descriptionOfWeekdayId
{
	return PYDayInWeek(_weekday);
}

@end
