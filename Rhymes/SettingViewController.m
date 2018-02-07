//
//  SettingViewController.m
//  Rhymes
//
//  Created by mypc on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "SettingViewController.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "Wordlist.h"

#define TABLEVIEW_TAG_START         100

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource> {
    int nTableWidth;
    int nTableHeight;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *txtIPA;
@property (weak, nonatomic) IBOutlet UILabel *txtFontsize;
@property (weak, nonatomic) IBOutlet UILabel *txtSpeed;
@property (weak, nonatomic) IBOutlet UIButton *upperBut;
@property (weak, nonatomic) IBOutlet UIButton *playBut;
@property (weak, nonatomic) IBOutlet UIStepper *stpFontsize;
@property (weak, nonatomic) IBOutlet UIStepper *stpSpeed;

@property (strong, nonatomic) Wordlist * wordlist;
@property (strong, nonatomic) NSTimer * scrollTimer;

- (IBAction)onUpperBut:(id)sender;
- (IBAction)onClostBut:(id)sender;
- (IBAction)onChangeFontBut:(id)sender;
- (IBAction)onChangeSpeedBut:(id)sender;
- (IBAction)onPlayBut:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _wordlist = [[AppDelegate sharedAppDelegate].arrayWordpack objectAtIndex:0];
    _scrollTimer = nil;
}

- (void)viewDidLayoutSubviews {
    
    if (nTableWidth > 0)  { return; }
    nTableWidth = _scrollView.bounds.size.width;
    nTableHeight = _scrollView.bounds.size.height;
    
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        [_upperBut setTitle:@"ABC" forState:UIControlStateNormal];
    }
    else {
        [_upperBut setTitle:@"abc" forState:UIControlStateNormal];
    }
    [_txtFontsize setText:[NSString stringWithFormat:@"%d pt", [AppDelegate sharedAppDelegate].nFontsize]];
    [_txtSpeed setText:[NSString stringWithFormat:@"%ds", [AppDelegate sharedAppDelegate].nSpeed]];
    _stpSpeed.value = [AppDelegate sharedAppDelegate].nSpeed;
    _stpFontsize.value = [AppDelegate sharedAppDelegate].nFontsize;
    
    NSArray *array = _wordlist.arryWord;
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
    _wordlist.nAverageWordWidth = (int)width / (int)array.count;
    
    UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, nTableWidth, nTableHeight)];
    myTableView.tag = TABLEVIEW_TAG_START;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.rowHeight = CELL_HEIGHT;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableView.allowsSelection = NO;
    myTableView.scrollEnabled = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    
    [_scrollView addSubview:myTableView];
    [myTableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
    [_scrollView setContentSize:CGSizeMake(nTableWidth, nTableHeight)];
    
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeHandle:)];
    upRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upSwipeHandle:)];
    downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [_scrollView addGestureRecognizer:upRecognizer];
    [_scrollView addGestureRecognizer:downRecognizer];
    
    //[AppDelegate sharedAppDelegate].bPlay = false;
    [self setScrollingTimer:[AppDelegate sharedAppDelegate].bPlay];
}

- (void)upSwipeHandle:(UISwipeGestureRecognizer *)gestureRecognizer {
    if ([AppDelegate sharedAppDelegate].bPlay) {
        [self setScrollingTimer:false];
    }
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self playScroll:true];
    }
    else {
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
    
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START];
    
    if (!isup) {
        int nOffset = (nTableHeight - CELL_HEIGHT * (OFFSET_CELL_COUNT + 1)) / CELL_HEIGHT + OFFSET_CELL_COUNT + 1;
        if (tableView.contentOffset.y <= -nOffset * CELL_HEIGHT) { return; }
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         if (isup)
                             [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y + CELL_HEIGHT)];
                         else
                             [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y - CELL_HEIGHT)];
                     }
                     completion:^(BOOL finished2) {
                         
                     }];
    if (tableView.contentOffset.y >= _wordlist.arryWord.count * CELL_HEIGHT) {
        [tableView setContentOffset:CGPointMake(0, -(OFFSET_CELL_COUNT + 1) * CELL_HEIGHT)];
        if ([AppDelegate sharedAppDelegate].bPlay) {
            [self onPlayBut:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - User Interface

- (IBAction)onClostBut:(id)sender {
    if (_scrollTimer != nil) {
        [_scrollTimer invalidate];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onUpperBut:(id)sender {
    [AppDelegate sharedAppDelegate].bUppercase = ![AppDelegate sharedAppDelegate].bUppercase;
    
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        [_upperBut setTitle:@"ABC" forState:UIControlStateNormal];
    }
    else {
        [_upperBut setTitle:@"abc" forState:UIControlStateNormal];
    }
    NSArray *array = _wordlist.arryWord;
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
    _wordlist.nAverageWordWidth = (int)width / (int)array.count;
    
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START];
    [tableView reloadData];
    
    [AppDelegate sharedAppDelegate].bSettingChange = true;
}

- (IBAction)onChangeFontBut:(id)sender {
    [AppDelegate sharedAppDelegate].nFontsize = (int)_stpFontsize.value;
    [_txtFontsize setText:[NSString stringWithFormat:@"%d pt", [AppDelegate sharedAppDelegate].nFontsize]];
    
    NSArray *array = _wordlist.arryWord;
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
    _wordlist.nAverageWordWidth = (int)width / (int)array.count;
    
    UITableView * tableView = [self.view viewWithTag:TABLEVIEW_TAG_START];
    [tableView reloadData];
    
    [AppDelegate sharedAppDelegate].bSettingChange = true;
}

- (IBAction)onChangeSpeedBut:(id)sender {
    [AppDelegate sharedAppDelegate].nSpeed = (int)_stpSpeed.value;
    [_txtSpeed setText:[NSString stringWithFormat:@"%ds", [AppDelegate sharedAppDelegate].nSpeed]];
    
    [self setScrollingTimer:[AppDelegate sharedAppDelegate].bPlay];
    
    [AppDelegate sharedAppDelegate].bSettingChange = true;
}

- (IBAction)onPlayBut:(id)sender {
    
    [AppDelegate sharedAppDelegate].bPlay = ![AppDelegate sharedAppDelegate].bPlay;
    
    [self setScrollingTimer:[AppDelegate sharedAppDelegate].bPlay];
    
    [AppDelegate sharedAppDelegate].bSettingChange = true;
}

- (void)setScrollingTimer:(BOOL)play {
    if (play) {
        [_playBut setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:true] forKey:@"isup"];
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:[AppDelegate sharedAppDelegate].nSpeed target:self selector:@selector(playScrollTimer:) userInfo:userInfo repeats:YES];
    }
    else {
        [_playBut setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        if (_scrollTimer != nil) {
            [_scrollTimer invalidate];
            _scrollTimer = nil;
        }
    }
}

#pragma mark - TableViewDelegate and  Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _wordlist.arryWord.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        UILabel *txtTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nTableWidth, CELL_HEIGHT)];
        [txtTemp setTextAlignment:NSTextAlignmentRight];
        txtTemp.tag = 105;
        [cell.contentView addSubview:txtTemp];
    }
    cell.txtWord.hidden = YES;
    
    NSString *word = [_wordlist.arryWord objectAtIndex:indexPath.row];
    word = [word stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    word = [word stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSInteger nPos = 0;
    if (![word isEqualToString:@""]) {
        nPos = word.length - _wordlist.strTitle.length;
        NSString *left = [word substringToIndex:nPos];
        NSString *right = [word substringFromIndex:nPos];
        word = [NSString stringWithFormat:@"%@%@", left, right];
    }
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        word = word.uppercaseString;
    }
    else {
        word = word.lowercaseString;
    }
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: cell.txtWord.textColor,
                              NSFontAttributeName: [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize]
                              };

    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:word
                                           attributes:attribs];
    
    
    UIColor *purpleColor = [AppDelegate colorFromHexString:ACTIVE_COLOR];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[AppDelegate sharedAppDelegate].nFontsize];
    NSRange purpleBoldTextRange;
    
    if ([AppDelegate sharedAppDelegate].bUppercase) {
        purpleBoldTextRange = [word rangeOfString:_wordlist.strTitle.uppercaseString];
    }
    else {
        purpleBoldTextRange = [word rangeOfString:_wordlist.strTitle.lowercaseString];
    }
    
    [attributedText setAttributes:@{NSForegroundColorAttributeName:purpleColor,
                                    NSFontAttributeName:boldFont}
                            range:purpleBoldTextRange];
    cell.txtWord.attributedText = attributedText;
    
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:105];
    [lbl setFrame:CGRectMake(0, 0, (nTableWidth + _wordlist.nAverageWordWidth) / 2 + 7, CELL_HEIGHT)];
    [attributedText addAttribute:NSKernAttributeName value:@(15.0) range:NSMakeRange(nPos-1, 1)];
    [lbl setAttributedText:attributedText];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
