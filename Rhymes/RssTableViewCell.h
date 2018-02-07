//
//  RssTableViewCell.h
//  Rhymes
//
//  Created by Akira on 5/21/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RssTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UILabel *txtPubDate;

@end
