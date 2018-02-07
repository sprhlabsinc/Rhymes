//
//  CustomTextField.m
//  Rhymes
//
//  Created by Akira on 6/6/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
        return NO;
    if (action == @selector(cut:))
        return NO;
    if (action == @selector(copy:))
        return NO;
    if (action == @selector(select:))
        return NO;
    if (action == @selector(selectAll:))
        return NO;
    if (action == NSSelectorFromString(@"_share:"))
        return NO;
    
    return [super canPerformAction:action withSender:sender];
}

@end
