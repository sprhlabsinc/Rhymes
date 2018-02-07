//
//  Wordlist.m
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "Wordlist.h"

@implementation Wordlist

-(id)init{
    self = [super init];
    if (self) {
        self.nid = 0;
        self.strTitle = @"";
        self.strIPA = @"";
        self.arryWord = nil;
        self.arryRandom = nil;
        self.bSelect = false;
        self.bFavorite = false;
        self.bRandom = false;
        self.nAverageWordWidth = 0;
        self.strFavTime = @"";
        self.bAlignment = false;
        self.nYPosition = -1;
    }
    return self;
}

@end
