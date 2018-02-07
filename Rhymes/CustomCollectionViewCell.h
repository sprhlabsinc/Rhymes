//
//  CustomCollectionViewCell.h
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *txtIPA;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@end
