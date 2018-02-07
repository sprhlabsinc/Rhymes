//
//  WordpackViewController.m
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "WordpackViewController.h"
#import "AppDelegate.h"
#import "CustomCollectionViewCell.h"
#import "Wordlist.h"
#import "CSVTarget.h"

@interface WordpackViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    int nScreenWidth;
}
- (IBAction)onCloseBut:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@property (strong, nonatomic) NSMutableArray * arrayWordpack;

@end

@implementation WordpackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _txtTitle.text = [AppDelegate sharedAppDelegate].strCSV;
    
    _arrayWordpack = [[NSMutableArray alloc] init];
    NSArray *array = [AppDelegate sharedAppDelegate].arrayWordpack;
    CSVTarget *csvTarget = [[AppDelegate sharedAppDelegate].dictCSV objectForKey:[AppDelegate sharedAppDelegate].strCSV];
    
    for (int i = csvTarget.nStart; i < csvTarget.nStart + csvTarget.nCount; i ++) {
        Wordlist *wordlist = [array objectAtIndex:i];
        [_arrayWordpack addObject:wordlist];
    }
    
    nScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [AppDelegate sharedAppDelegate].bWordpackChange = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((nScreenWidth - 20) / 3, (nScreenWidth - 20) / 3);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayWordpack.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier= @"customCollectionCell";
    
    CustomCollectionViewCell *cell = (CustomCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        NSString *nibNameOrNil= @"CustomCollectionViewCell";
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[CustomCollectionViewCell class]])
            {
                cell = (CustomCollectionViewCell*)currentObject;
                break;
            }
        }
    }
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:indexPath.row];
    cell.txtIPA.text = wordlist.strIPA;
    cell.txtTitle.text = wordlist.strTitle;
    
    if (wordlist.bSelect) {
        [cell setBackgroundColor:[AppDelegate colorFromHexString:@"#c5c5c5"]];
    }
    else {
        [cell setBackgroundColor:[AppDelegate colorFromHexString:@"#e4e4e4"]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:indexPath.row];
    wordlist.bSelect = !wordlist.bSelect;
    
    if (!wordlist.bSelect) {
        wordlist.bFavorite = false;
        wordlist.nYPosition = -1;
    }
    
    CustomCollectionViewCell *cell = (CustomCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (wordlist.bSelect) {
        [cell setBackgroundColor:[AppDelegate colorFromHexString:@"#c5c5c5"]];
    }
    else {
        [cell setBackgroundColor:[AppDelegate colorFromHexString:@"#e4e4e4"]];
    }
    [AppDelegate sharedAppDelegate].bWordpackChange = true;    
}

- (IBAction)onCloseBut:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
