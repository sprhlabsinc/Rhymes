//
//  AppDelegate.m
//  Rhymes
//
//  Created by mypc on 5/12/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "AppDelegate.h"
#import "Wordlist.h"
#import "CSVTarget.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"rssfeed.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO) {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS rss_tb (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, LINK TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_contactDB);
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }    
    
    _arrayWordpack = [[NSMutableArray alloc] init];
    _dictCSV = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *arryFavTemp = [prefs objectForKey:FAVORITE];
    NSArray *arryPackTemp = [prefs objectForKey:WORDPACK];
    NSArray *arryPackPosTemp = [prefs objectForKey:WORDPACKPOS];
    NSArray *arryYPositionTemp = [prefs objectForKey:YPOSITION];
    
    _nFontsize = (int)[prefs integerForKey:FONTSIZE] == 0 ? 50 : (int)[prefs integerForKey:FONTSIZE];
    _nSpeed = (int)[prefs integerForKey:SPEED] == 0 ? 3 : (int)[prefs integerForKey:SPEED];
    _bUppercase = [prefs boolForKey:UPPERCASE];
    _bPlay = [prefs boolForKey:PLAY];
    _bIsSetting = false;
    _nFavPos = (int)[prefs integerForKey:FAVORITEPOS];
    
    int nIDCount = 1;
    int nStart = 0;
    for (int k = 0; k < ArrayCSV.count; k ++) {
        NSString *sourceFileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[ArrayCSV objectAtIndex:k] ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray * arryWordpack = [[NSMutableArray alloc] init];
        arryWordpack = [[sourceFileString componentsSeparatedByString:@"\n"] mutableCopy];
        
        int nWordlistCnt = 0;
        for (int i = 0; i < arryWordpack.count; i ++ ) {
            NSString *keysString = [arryWordpack objectAtIndex:i];
            if ([keysString isEqualToString:@""]) {
                continue;
            }
            nWordlistCnt ++;
            
            Wordlist *wordlist = [[Wordlist alloc] init];
            wordlist.arryRandom = [[NSMutableArray alloc] init];
            
            NSArray *keysArray = [keysString componentsSeparatedByString:@","];
            NSMutableArray *wordArray = [[NSMutableArray alloc] init];
            
            for (int j = 2; j < keysArray.count; j ++) {
                NSString *word = [keysArray objectAtIndex:j];
                word = [word stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([word isEqualToString:@""]) { break; }
                
                [wordlist.arryRandom addObject:word];
                [wordArray addObject:word];
            }
            wordlist.nid = nIDCount ++;
            wordlist.strTitle = [keysArray objectAtIndex:0];
            wordlist.strIPA = [keysArray objectAtIndex:1];
            wordlist.arryWord = wordArray;
            wordlist.bFavorite = false;
            wordlist.bSelect = false;
            wordlist.bRandom = false;
            wordlist.bAlignment = false;
            
            // Set favorite ids
            if (arryFavTemp != nil) {
                for (int p = 0; p < arryFavTemp.count; p ++) {
                    NSString *temp = [arryFavTemp objectAtIndex:p];
                    NSArray *tA = [temp componentsSeparatedByString:@" "];
                    int nId = ((NSString *)[tA objectAtIndex:0]).intValue;
                    if (nId == wordlist.nid) {
                        wordlist.bFavorite = true;
                        wordlist.strFavTime = [tA objectAtIndex:1];
                        break;
                    }
                }
            }
            //set yposition
            if (arryYPositionTemp != nil) {
                for (int p = 0; p < arryYPositionTemp.count; p ++) {
                    NSString *temp = [arryYPositionTemp objectAtIndex:p];
                    NSArray *tA = [temp componentsSeparatedByString:@" "];
                    int nId = ((NSString *)[tA objectAtIndex:0]).intValue;
                    if (nId == wordlist.nid) {
                        wordlist.nYPosition = ((NSString *)[tA objectAtIndex:1]).floatValue;
                        break;
                    }
                }
            }
            
            // Set wordlist ids in wordpack
            if (arryPackTemp != nil) {
                for (int p = 0; p < arryPackTemp.count; p ++) {
                    int nId = ((NSString *)[arryPackTemp objectAtIndex:p]).intValue;
                    if (nId == wordlist.nid) {
                        wordlist.bSelect = true;
                        break;
                    }
                }
            }
            else {
                if (nWordlistCnt > 3) {
                    wordlist.bSelect = false;
                }
                else {
                    wordlist.bSelect = true;
                }
            }
            if ([((NSString *)[ArrayCSV objectAtIndex:k]) isEqualToString:@"xii"]) {
                wordlist.bAlignment = true;
            }
            
            [_arrayWordpack addObject:wordlist];
        }
        // Set start position and count, focus wordlist id from wordpack
        CSVTarget *csvTarget = [[CSVTarget alloc] init];
        csvTarget.nStart = nStart;
        csvTarget.nCount = nWordlistCnt;
        nStart += csvTarget.nCount;
        if (arryPackPosTemp != nil) {
            csvTarget.nPosition = ((NSString *)[arryPackPosTemp objectAtIndex:k]).intValue;
        }
        
        [_dictCSV setObject:csvTarget forKey:[ArrayCSV objectAtIndex:k]];
    }    
    
    return YES;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Save meta information such as speed, fontsize, wordpack, favorite ids etc.
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arryFavorite = [[NSMutableArray alloc] init];
    NSMutableArray *arryWordpack = [[NSMutableArray alloc] init];
    NSMutableArray *arryPackPos = [[NSMutableArray alloc] init];
    NSMutableArray *arryYPosition = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <_arrayWordpack.count; i ++) {
        Wordlist *wordlist = [_arrayWordpack objectAtIndex:i];
        if (wordlist.bSelect && wordlist.bFavorite) {
            [arryFavorite addObject:[NSString stringWithFormat:@"%d %@", wordlist.nid, wordlist.strFavTime]];
        }
        if (wordlist.bSelect) {
            [arryWordpack addObject:[NSString stringWithFormat:@"%d", wordlist.nid]];
        }
        if (wordlist.nYPosition != -1) {
            [arryYPosition addObject:[NSString stringWithFormat:@"%d %f", wordlist.nid, wordlist.nYPosition]];
        }
    }
    [prefs setObject:arryFavorite forKey:FAVORITE];
    [prefs setObject:arryWordpack forKey:WORDPACK];
    [prefs setObject:arryYPosition forKey:YPOSITION];
    
    [prefs setBool:[AppDelegate sharedAppDelegate].bUppercase forKey:UPPERCASE];
    [prefs setInteger:[AppDelegate sharedAppDelegate].nFontsize forKey:FONTSIZE];
    [prefs setInteger:[AppDelegate sharedAppDelegate].nSpeed forKey:SPEED];
    [prefs setBool:[AppDelegate sharedAppDelegate].bPlay forKey:PLAY];
    
    for (int i = 0; i < ArrayCSV.count; i ++) {
        CSVTarget *csvTarget =  [_dictCSV objectForKey:[ArrayCSV objectAtIndex:i]];
        [arryPackPos addObject:[NSString stringWithFormat:@"%d", csvTarget.nPosition]];
    }
    [prefs setObject:arryPackPos forKey:WORDPACKPOS];
    [prefs setObject:[NSString stringWithFormat:@"%d", _nFavPos] forKey:FAVORITEPOS];
    
    [prefs synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}


@end
