//
//  CustomCollectionViewCell.m
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "AppDelegate.h"

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_txtTitle setTextColor:[AppDelegate colorFromHexString:ACTIVE_COLOR]];
}


@end
