//
//  WordlistViewController.m
//  Rhymes
//
//  Created by mypc on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "WordlistViewController.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "Wordlist.h"
#import "CSVTarget.h"
#import "CustomTextField.h"

#define TABLEVIEW_TAG_START         1000

@interface WordlistViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    int nTableWidth;
    int nTableHeight;
    BOOL bRestart;
    int nOffsets[100];
    BOOL bStart;
    BOOL bStop;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *txtIPA;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBut;
@property (weak, nonatomic) IBOutlet UIButton *shuffleBut;
@property (weak, nonatomic) IBOutlet UIButton *settingBut;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIImageView *lookupView;

@property (strong, nonatomic) NSMutableArray * arrayWordpack;
@property (strong, nonatomic) NSTimer * scrollTimer;

- (IBAction)onHomeBut:(id)sender;
- (IBAction)onFavoriteBut:(id)sender;
- (IBAction)onRandomBut:(id)sender;

@end

@implementation WordlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrayWordpack = [[NSMutableArray alloc] init];
    _txtIPA.text = @"";
    _scrollTimer = nil;
    bStart = false;
    bStop = false;
    [AppDelegate sharedAppDelegate].bWordpackChange = true;
    [AppDelegate sharedAppDelegate].bSettingChange = false;
    [AppDelegate sharedAppDelegate].bIsSetting = false;
    
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeHandle:)];
    upRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeHandle:)];
    downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [_scrollView addGestureRecognizer:upRecognizer];
    [_scrollView addGestureRecognizer:downRecognizer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseSwipeHandle:)];
    tapGesture.numberOfTapsRequired = 2;
    [_swipeView addGestureRecognizer:tapGesture];
}

- (void)pauseSwipeHandle:(UISwipeGestureRecognizer *)UITapGestureRecognizer {
    if (_arrayWordpack.count == 0) { return; }
    
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + _pageControl.currentPage];
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:_pageControl.currentPage];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [tableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
                         wordlist.nYPosition = -1;
                     }
                     completion:^(BOOL finished2) {
                         
                     }];
}

- (void)viewDidLayoutSubviews {
    
    nTableWidth = _scrollView.bounds.size.width;
    nTableHeight = _scrollView.bounds.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (bStart) {
        for (int i = 0 ; i < _arrayWordpack.count; i ++) {
            UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + i];
            [tableView setContentOffset:CGPointMake(0, nOffsets[i])];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadWordlist];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (int i = 0 ; i < _arrayWordpack.count; i ++) {
        UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + i];
        nOffsets[i] = tableView.contentOffset.y;
    }
    bStart = true;
}

- (void)loadWordlist {
    if ([AppDelegate sharedAppDelegate].bIsSetting) {
        if ([AppDelegate sharedAppDelegate].bSettingChange) {
            [AppDelegate sharedAppDelegate].bSettingChange = false;
            
            Wordlist *wordlist = [_arrayWordpack objectAtIndex:_pageControl.currentPage];
            NSArray *array = wordlist.arryWord;
            float width = 0;
            for (int i = 0; i < array.count; i ++) {
                NSString *title = [array objectAtIndex:i];
                if ([AppDelegate sharedAppDelegate].bUppercase) {
                    title = title.uppercaseString;
                }
                title = [NSString stringWithFormat:@"%@ ",title];
                CGSize size = CGSizeMake(nTableWidth, CELL_HEIGHT);
                UIFont *font = [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize];
                
                width += [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
            }
            wordlist.nAverageWordWidth = (int)width / (int)array.count;
            
            UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + _pageControl.currentPage];
            [tableView reloadData];
        }
        if ([AppDelegate sharedAppDelegate].bPlay) {
            [self setScrollingTimer:true];
        }
        return;
    }
    
    if (![AppDelegate sharedAppDelegate].bWordpackChange) {
        if ([AppDelegate sharedAppDelegate].bPlay) {
            [self setScrollingTimer:true];
        }
    }
    else {
        _txtIPA.text = @"";
        bRestart = false;
        [self setScrollingTimer:false];
        [_favoriteBut setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        [_shuffleBut setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
        
        [_arrayWordpack removeAllObjects];
        for (UIView *v in _scrollView.subviews) {
            [v removeFromSuperview];
        }
        
        NSArray *array = [AppDelegate sharedAppDelegate].arrayWordpack;
        CSVTarget *csvTarget = [[AppDelegate sharedAppDelegate].dictCSV objectForKey:[AppDelegate sharedAppDelegate].strCSV];

        for (int i = csvTarget.nStart; i < csvTarget.nStart + csvTarget.nCount; i ++) {
            Wordlist *wordlist = [array objectAtIndex:i];
            if (wordlist.bSelect) {
                [_arrayWordpack addObject:wordlist];
            }
        }
        int nPagePos = 0;
        for (int i = 0; i < _arrayWordpack.count; i ++) {
            Wordlist *wordlist = [_arrayWordpack objectAtIndex:i];
            NSArray *array = wordlist.arryWord;
            float width = 0;
            for (int i = 0; i < array.count; i ++) {
                NSString *title = [array objectAtIndex:i];
                if ([AppDelegate sharedAppDelegate].bUppercase) {
                    title = title.uppercaseString;
                }
                title = [NSString stringWithFormat:@"%@ ",title];
                CGSize size = CGSizeMake(nTableWidth, CELL_HEIGHT);
                UIFont *font = [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize];
                
                width += [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
            }
            wordlist.nAverageWordWidth = (int)width / (int)array.count;
            
            UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(i * nTableWidth, 0, nTableWidth, nTableHeight)];
            myTableView.tag = TABLEVIEW_TAG_START + i;
            myTableView.delegate = self;
            myTableView.dataSource = self;
            myTableView.rowHeight = CELL_HEIGHT;
            myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            myTableView.allowsSelection = NO;
            myTableView.scrollEnabled = NO;
            myTableView.backgroundColor = [UIColor clearColor];
            
            [_scrollView addSubview:myTableView];
            //if (wordlist.nYPosition == -1)
                [myTableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
            //else
              //  [myTableView setContentOffset:CGPointMake(0, wordlist.nYPosition)];
            
            if (wordlist.nid == csvTarget.nPosition)
                nPagePos = i;
        }
        [_scrollView setContentSize:CGSizeMake(_arrayWordpack.count * nTableWidth, nTableHeight)];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = _arrayWordpack.count;
        [_scrollView setContentOffset:CGPointMake(0, 0)];
        if (_arrayWordpack.count != 0 ) {
            
            // move focus wordlist
            [_scrollView setContentOffset:CGPointMake(nTableWidth * nPagePos, 0)];
            [self loadTableView:nPagePos];
            
            [self setScrollingTimer:[AppDelegate sharedAppDelegate].bPlay];
            [_settingBut setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
            
            [_favoriteBut setEnabled:true];
            [_shuffleBut setEnabled:true];
            [_settingBut setEnabled:true];
            [_lookupView setHidden:NO];
        }
        else {
            [_favoriteBut setImage:[UIImage imageNamed:@"g_star"] forState:UIControlStateNormal];
            [_shuffleBut setImage:[UIImage imageNamed:@"g_shuffle"] forState:UIControlStateNormal];
            [_settingBut setImage:[UIImage imageNamed:@"g_gear"] forState:UIControlStateNormal];
            
            [_favoriteBut setEnabled:false];
            [_shuffleBut setEnabled:false];
            [_settingBut setEnabled:false];
            [_lookupView setHidden:YES];
        }
    }
}

- (void)upSwipeHandle:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_arrayWordpack.count == 0) { return; }
    bRestart = true;
    
    if ([AppDelegate sharedAppDelegate].bPlay) {
        [self setScrollingTimer:false];
    }
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        bStop = false;
        [self playScroll:true];
    }
    else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        bStop = true;
        [self playScroll:false];
    }
    if ([AppDelegate sharedAppDelegate].bPlay) {
        [self setScrollingTimer:true];
    }    
}

- (void)playScrollTimer:(NSTimer *)timer {
    NSDictionary *userInfo = [timer userInfo];
    NSNumber *isup = [userInfo objectForKey:@"isup"];
    [self playScroll:isup.boolValue];
}

- (void)playScroll:(BOOL)isup {
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + _pageControl.currentPage];
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:_pageControl.currentPage];
    
    if (!isup) {
        int nOffset = (nTableHeight - CELL_HEIGHT * (OFFSET_CELL_COUNT + 1)) / CELL_HEIGHT + OFFSET_CELL_COUNT + 1;
        if (tableView.contentOffset.y <= -nOffset * CELL_HEIGHT) { return; }
    }
    if ([AppDelegate sharedAppDelegate].bPlay && !bRestart && tableView.contentOffset.y == -CELL_HEIGHT * (OFFSET_CELL_COUNT + 1)) {
        return;
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         if (isup) {
                             if (!bStop)
                                 [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y + CELL_HEIGHT)];
                         }
                         else
                             [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y - CELL_HEIGHT)];
                     }
                     completion:^(BOOL finished2) {
                         [tableView reloadData];
                     }];
    if (tableView.contentOffset.y >= wordlist.arryWord.count * CELL_HEIGHT) {
        [tableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
    }
    wordlist.nYPosition = tableView.contentOffset.y;
    bRestart = false;
}

#pragma mark - User Interface

- (IBAction)onHomeBut:(id)sender {
    if (_scrollTimer != nil) {
        [_scrollTimer invalidate];
        _scrollTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onFavoriteBut:(id)sender {
    if (_arrayWordpack.count == 0) { return; }
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:_pageControl.currentPage];
    
    wordlist.bFavorite = !wordlist.bFavorite;
    if (wordlist.bFavorite) {
        [_favoriteBut setImage:[UIImage imageNamed:@"starSelected"] forState:UIControlStateNormal];
        wordlist.strFavTime = TimeStamp;
    }
    else {
        [_favoriteBut setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }    
}

- (IBAction)onRandomBut:(id)sender {
    if (_arrayWordpack.count == 0) { return; }
    
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:_pageControl.currentPage];
    
    wordlist.bRandom = !wordlist.bRandom;
    if (wordlist.bRandom) {
        [_shuffleBut setImage:[UIImage imageNamed:@"shuffleSelected"] forState:UIControlStateNormal];
        
        int count = (int)[wordlist.arryRandom count];
        for (int i = 0; i < count; ++i) {
            int nElements = count - i;
            int n = (arc4random() % nElements) + i;
            [wordlist.arryRandom exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
    else {
        [_shuffleBut setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
    }
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + _pageControl.currentPage];
    [tableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
    wordlist.nYPosition = -1;
    [tableView reloadData];
}

- (void)setScrollingTimer:(BOOL)play {
    if (play) {
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:true] forKey:@"isup"];
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:[AppDelegate sharedAppDelegate].nSpeed target:self selector:@selector(playScrollTimer:) userInfo:userInfo repeats:YES];
    }
    else {
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"start scrolling");
    if ([AppDelegate sharedAppDelegate].bPlay) {
        [self setScrollingTimer:false];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"end scrolling");
    if ([AppDelegate sharedAppDelegate].bPlay) {
        [self setScrollingTimer:true];
    }
    
    int nPage = _scrollView.contentOffset.x / (_scrollView.contentSize.width / _arrayWordpack.count);
    [self loadTableView:nPage];
}

- (void)loadTableView:(int)nPage {
    
    _pageControl.currentPage = nPage;
    
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:nPage];
    _txtIPA.text = wordlist.strIPA;
    
    CSVTarget *csvTarget = [[AppDelegate sharedAppDelegate].dictCSV objectForKey:[AppDelegate sharedAppDelegate].strCSV];
    csvTarget.nPosition = wordlist.nid;
    
    if (wordlist.bFavorite) {
        [_favoriteBut setImage:[UIImage imageNamed:@"starSelected"] forState:UIControlStateNormal];
    }
    else {
        [_favoriteBut setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }
    if (wordlist.bRandom) {
        [_shuffleBut setImage:[UIImage imageNamed:@"shuffleSelected"] forState:UIControlStateNormal];
    }
    else {
        [_shuffleBut setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
    }
    NSArray *array = wordlist.arryWord;
    float width = 0;
    for (int i = 0; i < array.count; i ++) {
        NSString *title = [array objectAtIndex:i];
        if ([AppDelegate sharedAppDelegate].bUppercase) {
            title = title.uppercaseString;
        }
        title = [NSString stringWithFormat:@"%@ ",title];
        CGSize size = CGSizeMake(nTableWidth, CELL_HEIGHT);
        UIFont *font = [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize];
        
        width += [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
    }
    wordlist.nAverageWordWidth = (int)width / (int)array.count;
    
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START + _pageControl.currentPage];
    [tableView reloadData];

}

#pragma mark - TableViewDelegate and  Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger tag = tableView.tag - TABLEVIEW_TAG_START;
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:tag];
    
    return wordlist.arryWord.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = tableView.tag - TABLEVIEW_TAG_START;
    Wordlist *wordlist = [_arrayWordpack objectAtIndex:tag];
    
    static NSString *CellIdentifier= @"customCell";
    
    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSString *nibNameOrNil= @"CustomTableViewCell";
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[CustomTableViewCell class]])
            {
                cell = (CustomTableViewCell*)currentObject;
                break;
            }
        }
        CGRect rect = CGRectMake(0, 0, (nTableWidth + wordlist.nAverageWordWidth) / 2, CELL_HEIGHT);
        if (wordlist.bAlignment) {
            rect = CGRectMake((nTableWidth - wordlist.nAverageWordWidth) / 2, 0, wordlist.nAverageWordWidth + (nTableWidth - wordlist.nAverageWordWidth) / 2, CELL_HEIGHT);
        }
        CustomTextField *txtTemp = [[CustomTextField alloc] initWithFrame:rect];
        [txtTemp setEditable:NO];
        [txtTemp setBackgroundColor:[UIColor clearColor]];
        [txtTemp setScrollEnabled:NO];
        
        [txtTemp setTextAlignment:NSTextAlignmentRight];
        if (wordlist.bAlignment)
            [txtTemp setTextAlignment:NSTextAlignmentLeft];
        txtTemp.tag = 105;
        [cell.contentView addSubview:txtTemp];
    }
    cell.txtWord.hidden = YES;
    
    NSString *word = [wordlist.arryWord objectAtIndex:indexPath.row];
    if (wordlist.bRandom) {
        word = [wordlist.arryRandom objectAtIndex:indexPath.row];
    }
    word = [word stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    word = [word stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSInteger nPos = 0;
    if (![word isEqualToString:@""]) {
        if (!wordlist.bAlignment) {
            nPos = word.length - wordlist.strTitle.length;
            NSString *left = [word substringToIndex:nPos];
            NSString *right = [word substringFromIndex:nPos];
            word = [NSString stringWithFormat:@"%@%@", left, right];
        }
        else {
            nPos = wordlist.strTitle.length;
            NSString *left = [word substringToIndex:nPos];
            NSString *right = [word substringFromIndex:nPos];
            word = [NSString stringWithFormat:@"%@%@", left, right];
        }
    }
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        word = word.uppercaseString;
    }
    else {
        word = word.lowercaseString;
    }
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: [UIColor blackColor],
                              NSFontAttributeName: [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize]
                              };
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:word
                                           attributes:attribs];
    
    
    UIColor *purpleColor = [AppDelegate colorFromHexString:ACTIVE_COLOR];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize];
    NSRange purpleBoldTextRange;
    
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        purpleBoldTextRange = [word rangeOfString:wordlist.strTitle.uppercaseString];
    }
    else {
        purpleBoldTextRange = [word rangeOfString:wordlist.strTitle.lowercaseString];
    }
    
    [attributedText setAttributes:@{NSForegroundColorAttributeName:purpleColor,
                                    NSFontAttributeName:boldFont}
                            range:purpleBoldTextRange];
    
    CustomTextField *lbl = (CustomTextField *)[cell.contentView viewWithTag:105];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (!wordlist.bAlignment) {
        [paragraphStyle setAlignment:NSTextAlignmentRight];
        [lbl setFrame:CGRectMake(0, 0, (nTableWidth + wordlist.nAverageWordWidth) / 2 + 7, CELL_HEIGHT)];
    }
    else {
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [lbl setFrame:CGRectMake((nTableWidth - wordlist.nAverageWordWidth) / 2 - 7, 0, wordlist.nAverageWordWidth + (nTableWidth - wordlist.nAverageWordWidth) / 2, CELL_HEIGHT)];
    }
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSKernAttributeName value:@(15.0) range:NSMakeRange(nPos-1, 1)];

    
    [lbl setAttributedText:attributedText];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"setting"]) {
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
        [AppDelegate sharedAppDelegate].bIsSetting = true;
    }
    else if ([segue.identifier isEqualToString:@"wordpack"]) {
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
        [AppDelegate sharedAppDelegate].bIsSetting = false;
    }
}

@end
