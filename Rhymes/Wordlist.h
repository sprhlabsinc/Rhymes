//
//  Wordlist.h
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Wordlist : NSObject

@property (nonatomic, assign) int nid;
@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSString *strIPA;
@property (strong, nonatomic) NSArray *arryWord;
@property (strong, nonatomic) NSMutableArray *arryRandom;
@property (nonatomic, assign) BOOL bSelect;
@property (nonatomic, assign) BOOL bFavorite;
@property (nonatomic, assign) BOOL bRandom;
@property (nonatomic, assign) int nAverageWordWidth;
@property (strong, nonatomic) NSString *strFavTime;
@property (nonatomic, assign) BOOL bAlignment;
@property (nonatomic, assign) float nYPosition;

@end
