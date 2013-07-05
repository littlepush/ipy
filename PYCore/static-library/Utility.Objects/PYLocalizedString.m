//
//  PYLocalizedString.m
//  PYCore
//
//  Created by Push Chen on 6/10/13.
//  Copyright (c) 2013 PushLab. All rights reserved.
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

#import "PYLocalizedString.h"
#import "PYCoreMacro.h"
#import "NSObject+PYCore.h"
#import "NSArray+PYCore.h"

static PYLocalizedString *_gPYString = nil;

// Language identifiers
NSString *const  PYLanguageEnglish                  = @"en";
NSString *const  PYLanguageChineseSimplified        = @"zh-Hans";
NSString *const  PYLanguageChineseTraditional       = @"zh-Hant";
NSString *const  PYLanguageFrench                   = @"fr";
NSString *const  PYLanguageGerman                   = @"de";
NSString *const  PYLanguageJapanese                 = @"ja";
NSString *const  PYLanguageKorean                   = @"ko";

#define SS          ([PYLocalizedString sharedStrings])

@implementation PYLocalizedString

#pragma mark --
#pragma mark Singleton

+ (PYLocalizedString *)sharedStrings
{
    @synchronized( self ) {
        if ( _gPYString == nil ) {
            _gPYString = [[PYLocalizedString alloc] init];
        }
        return _gPYString;
    }
}
PYSingletonAllocWithZone(_gPYString)
PYSingletonDefaultImplementation

- (id)init
{
    self = [super init];
    if ( self ) {
        _systemLanguage = [[NSLocale preferredLanguages] safeObjectAtIndex:0];
        if ( [_systemLanguage length] == 0 ) {
            _systemLanguage = PYLanguageEnglish;
        }
        _defaultLanguage = _systemLanguage;
        
        // Initialize the dict
        _stringDict = [NSMutableDictionary dictionary];
    }
    return self;
}

// The default language identify.
// When specified language is not supported in current dict,
// any string getting operator will return the default language
// string.
- (NSString *)defaultLanguage
{
    return _defaultLanguage;
}

+ (NSString *)defaultLanguage
{
    return [SS defaultLanguage];
}
- (void)setDefaultLanguage:(NSString *)language
{
    _defaultLanguage = language;
}
+ (void)setDefaultLanguage:(NSString *)language
{
    [SS setDefaultLanguage:language];
}

// Add String to the dictionary, for different language.
- (void)addStrings:(NSDictionary *)strings forKey:(NSString *)key
{
    @synchronized(self) {
        for ( NSString *_language in strings ) {
            NSMutableDictionary *_dict = [_stringDict objectForKey:_language];
            if ( _dict == nil ) {
                _dict = [NSMutableDictionary dictionary];
                [_stringDict setValue:_dict forKey:_language];
            }
            [_dict setValue:[strings objectForKey:_language] forKey:key];
        }
    }
}
+ (void)addStrings:(NSDictionary *)strings forKey:(NSString *)key
{
    [SS addStrings:strings forKey:key];
}

// Get the string specified by key as current system language
- (NSString *)stringForKey:(NSString *)key
{
    @synchronized(self) {
        NSDictionary *_stringTable = [_stringDict objectForKey:_systemLanguage];
        if ( _stringTable == nil ) {
            _stringTable = [_stringTable objectForKey:_defaultLanguage];
        }
        if ( _stringTable == nil ) return key;
        return [_stringTable objectForKey:key];
    }
}
+ (NSString *)stringForKey:(NSString *)key
{
    return [SS stringForKey:key];
}
// Get the string specified by key as specified language
- (NSString *)stringForKey:(NSString *)key withLanguage:(NSString *)language
{
    @synchronized(self) {
        NSDictionary *_stringTable = [_stringDict objectForKey:language];
        if ( _stringTable == nil ) return key;
        return [_stringTable objectForKey:key];
    }
}
+ (NSString *)stringForKey:(NSString *)key withLanguage:(NSString *)language
{
    return [SS stringForKey:key withLanguage:language];
}

@end

// @littlepush
// littlepush@gmail.com
// PYLab
