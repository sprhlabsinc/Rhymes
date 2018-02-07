//
//  AppDelegate.h
//  Rhymes
//
//  Created by mypc on 5/12/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define CELL_HEIGHT                 70
#define ACTIVE_COLOR                @"#400080"

#define OFFSET_CELL_COUNT           1
#define ANIMATION_DURATION          0.2

#define FAVORITE                    @"FAVORITE"
#define WORDPACK                    @"WORDPACK"
#define YPOSITION                   @"YPOSITION"
#define WORDPACKPOS                 @"WORDPACKPOS"
#define FAVORITEPOS                 @"FAVORITEPOS"
#define UPPERCASE                   @"UPPERCASE"
#define FONTSIZE                    @"FONTSIZE"
#define SPEED                       @"SPEED"
#define PLAY                        @"PLAY"
#define EMAIL                       @"EMAIL"
#define EMAIL_VERIFIED              @"EMAIL_VERIFIED"
#define RSSFEED                     @"RSSFEED"

#define TimeStamp                   [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]
#define ArrayCSV                    [NSArray arrayWithObjects:@"a", @"e", @"i", @"o", @"u", @"vi", @"vii", @"iix", @"ix", @"x", @"xi", @"xii", nil]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *arrayWordpack;
@property (strong, nonatomic) NSMutableDictionary *dictCSV;
@property (strong, nonatomic) NSString *strCSV;

@property (nonatomic, assign) BOOL bUppercase;
@property (nonatomic, assign) int nFontsize;
@property (nonatomic, assign) int nSpeed;
@property (nonatomic, assign) BOOL bPlay;
@property (nonatomic, assign) BOOL bWordpackChange;
@property (nonatomic, assign) BOOL bSettingChange;
@property (nonatomic, assign) BOOL bIsSetting;
@property (nonatomic, assign) int nFavPos;

@property (nonatomic, assign) sqlite3 *contactDB;
@property (nonatomic, strong) NSString *databasePath;

+ (AppDelegate *)sharedAppDelegate;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end

