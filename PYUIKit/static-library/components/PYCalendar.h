//
//  PYCalendar.h
//  PYUIKit
//
//  Created by Push Chen on 7/27/12.
//  Copyright (c) 2012 Push Lab. All rights reserved.
//

#import "PYComponentView.h"

#define PYCalendarDateCellIdentify		@"kPYCalendarDateCellIdentify"

@protocol PYCalendarDataSource;
@protocol PYCalendarDelegate;

@class PYCalendarDateCell;
@class PYCalendarYearMonthView;
@class PYCalendarWeekDescriptCell;

@interface PYCalendar : PYComponentView
{
	id							_dateItemMatrix[PYCalendarWeeksInMonth][PYCalendarDaysInWeek];
	NSUInteger					_currentYear;
	NSUInteger					_currentMonth;
	NSUInteger					_currentDay;
	
	NSUInteger					_todayYear;
	NSUInteger					_todayMonth;
	NSUInteger					_todayDay;
	
	NSInteger					_firstDayOfMonth;
	
	PYCalendarYearMonthView		*_yearMonthView;
	BOOL						_showYearMonthView;
	id							_dayInWeekName[PYCalendarDaysInWeek];
	BOOL						_showWeekdayName;
	
	BOOL						_showCacheDay;
	
	id< PYCalendarDataSource >	_datasource;
	id< PYCalendarDelegate >	_delegate;
	
	UIImageView					*_backgroundImageView;
	NSMutableDictionary			*_dayCellCache;
}

+(PYWeekDay) firstDayInWeekOfYear:(NSUInteger)year month:(NSUInteger)month;
+(NSUInteger) daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

@property (nonatomic, readonly) NSUInteger		currentYear;
@property (nonatomic, readonly) NSUInteger		currentMonth;

@property (nonatomic, assign)	BOOL			showYearMonthView;
@property (nonatomic, assign)	BOOL			showWeekdayName;

@property (nonatomic, retain)	UIImageView		*backgroundImageView;
@property (nonatomic, readonly)	PYCalendarYearMonthView	*yearMonthView;

@property (nonatomic, retain) IBOutlet	id< PYCalendarDelegate >	delegate;
@property (nonatomic, retain) IBOutlet	id< PYCalendarDataSource >	datasource;

-(void) reloadData;
-(void) gotoToday;

-(void) gotoPreviousMonth;
-(void) gotoNextMonth;
-(void) gotoPreviousYear;
-(void) gotoNextYear;

-(PYCalendarDateCell *) cellOfDay:(NSUInteger)day;
-(NSArray *) cellsOfWeekday;
-(NSArray *) cellsOfWeekend;
-(NSArray *) cellsOfDayAs:(PYWeekDay)wd;
-(NSArray *) cellsofWeek:(NSUInteger)weekIndex;

-(PYCalendarDateCell *) dequeueReusableDateCellForIdentify:(NSString *)identify;

@end

typedef enum {
	PYCalendarDateCellTypeWeekday,
	PYCalendarDateCellTypeWeekend
} PYCalendarDateCellType;

typedef enum {
	PYCalendarDateCellSelectionStyleNone = 0,
	PYCalendarDateCellSelectionStyleBlue,
	PYCalendarDateCellSelectionStyleGray
} PYCalendarDateCellSelectionStyle;

@interface PYCalendarDateCell : PYTouchView
{
	NSString			*_reusableIdentify;
	UILabel				*_dayLabel;
	UIImageView			*_backgroundImageView;
	
	PYCalendarDateCellType	_cellType;
	PYCalendarDateCellSelectionStyle _cellSelectionStyle;
	
	PYCalendarDate		_dateInfo;
	
	NSDate				*_theDate;
	
	PYCalendar			*_calendar;
}

@property (nonatomic, retain)	NSString		*reusableIdentify;
@property (nonatomic, readonly) NSDate			*date;
@property (nonatomic, readonly) NSUInteger		year;
@property (nonatomic, readonly) NSUInteger		month;
@property (nonatomic, readonly) NSUInteger		day;
@property (nonatomic, readonly) PYWeekDay		dayInWeek;
@property (nonatomic, readonly) PYCalendarDate	dateInfo;
@property (nonatomic, readonly) BOOL			isWeekDay;
@property (nonatomic, readonly) BOOL			isWeekEnd;
@property (nonatomic, assign)	
	PYCalendarDateCellSelectionStyle		selectionStyle;

@property (nonatomic, retain)	UILabel		*dayLabel;
@property (nonatomic, retain)	UIImageView	*backgroundImageView;

@property (nonatomic, readonly) PYCalendar	*calendar;

-(id) initDateCellWithType:(PYCalendarDateCellType)type 
	reusableIdentify:(NSString *)identify;

-(void) prepareForReuse;
-(void) cellUpdateDateInformation;
-(void) cellIsCacheDate:(BOOL)isCache;

@end

@interface PYCalendarYearMonthView : PYTouchView
{
	UILabel				*_yearMonthLabel;
	NSDate				*_date;
	NSUInteger			_year;
	NSUInteger			_month;
	NSString			*_format;
	
	UIButton			*_prevYearButton;
	UIButton			*_prevMonthButton;
	UIButton			*_nextMonthButton;
	UIButton			*_nextYearButton;
	
	UISwipeGestureRecognizer	*_swipeLeftGesture;
	UISwipeGestureRecognizer	*_swipeRightGesture;
	BOOL				_swipeToChangeMonth;
	PYCalendar			*_calendar;
	
	BOOL				_showYearButton;
	BOOL				_showMonthButton;
}

@property (nonatomic, readonly) PYCalendar	*calendar;
@property (nonatomic, assign, setter = setSwipeToChangeMonth:) 
	BOOL				isSwipeToChangeMonth;
@property (nonatomic, assign, setter = setShowMonthSwitchButton:)
	BOOL				isShowMonthSwitchButton;
@property (nonatomic, assign, setter = setShowYearSwitchButton:)
	BOOL				isShowYearSwitchButton;
@property (nonatomic, retain)	UILabel		*yearMonthLabel;

-(void) setYear:(NSUInteger)year month:(NSUInteger)month;

-(void) setFormat:(NSString *)format;

@end

@interface PYCalendarWeekDescriptCell : PYTouchView
{
	UILabel				*_weekdayDescriptionLabel;
	PYCalendar			*_calendar;
	
	PYWeekDay			_weekday;
}

@property (nonatomic, readonly) PYCalendar	*calendar;
@property (nonatomic, readonly) PYWeekDay	weekdayId;
@property (nonatomic, retain)	UILabel		*weekdayDescriptionLabel;

-(NSString *) descriptionOfWeekdayId;

@end

@protocol PYCalendarDataSource <NSObject>

@optional
-(PYCalendarDateCell *) pyCalendar:(PYCalendar *)calendar dateCellOfDate:(PYCalendarDate)date;

-(PYCalendarWeekDescriptCell *) pyCalendar:(PYCalendar *)calendar weekdayId:(PYWeekDay)weekdayId;

-(PYCalendarYearMonthView *) pyCalendarYearMonthView:(PYCalendar *)calendar;

-(CGFloat) pyCalendarYearMonthViewHeight:(PYCalendar *)calendar;

-(CGFloat) pyCalendarWeekdayDescripitionHeight:(PYCalendar *)calendar;

@end

@protocol PYCalendarDelegate <NSObject>

@optional

-(void) pyCalendar:(PYCalendar *)calendar changeToDate:(PYCalendarDate)date;

-(void) pyCalendar:(PYCalendar *)calendar didSelectedDate:(PYCalendarDate)date;

-(void) pyCalendar:(PYCalendar *)calendar selectedWeekdayID:(PYWeekDay)weekdayId;

@end

