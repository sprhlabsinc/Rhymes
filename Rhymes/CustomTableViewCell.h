//
//  CustomTableViewCell.h
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *txtWord;
@end
