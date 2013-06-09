//
//  PYLocalizedString.h
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

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    // Common used language
    extern NSString *const  PYLanguageEnglish;
    extern NSString *const  PYLanguageChineseSimplified;
    extern NSString *const  PYLanguageChineseTraditional;
    extern NSString *const  PYLanguageFrench;
    extern NSString *const  PYLanguageGerman;
    extern NSString *const  PYLanguageJapanese;
    extern NSString *const  PYLanguageKorean;
    
#ifdef __cplusplus
}
#endif

@interface PYLocalizedString : NSObject
{
    NSMutableDictionary             *_stringDict;
    NSString                        *_systemLanguage;
    NSString                        *_defaultLanguage;
}

// Singleton
+ (PYLocalizedString *)sharedStrings;

// The default language identify.
// When specified language is not supported in current dict,
// any string getting operator will return the default language
// string.
- (NSString *)defaultLanguage;
+ (NSString *)defaultLanguage;
- (void)setDefaultLanguage:(NSString *)language;
+ (void)setDefaultLanguage:(NSString *)language;

// Add String to the dictionary, for different language.
- (void)addStrings:(NSDictionary *)strings forKey:(NSString *)key;
+ (void)addStrings:(NSDictionary *)strings forKey:(NSString *)key;

// Get the string specified by key as current system language
- (NSString *)stringForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
// Get the string specified by key as specified language
- (NSString *)stringForKey:(NSString *)key withLanguage:(NSString *)language;
+ (NSString *)stringForKey:(NSString *)key withLanguage:(NSString *)language;

@end

// @littlepush
// littlepush@gmail.com
// PYLab
