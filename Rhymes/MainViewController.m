//
//  MainViewController.m
//  Rhymes
//
//  Created by mypc on 5/12/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "Reachability.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) Boolean bAssignIcon;
- (IBAction)onMailBut:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bAssignIcon = true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_activityIndicator stopAnimating];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL emailVerified = [prefs boolForKey:EMAIL_VERIFIED];
    if (emailVerified && _bAssignIcon) {
        _bAssignIcon = false;
        for (int i = 101; i <= 112; i ++) {
            NSString *identifier = [ArrayCSV objectAtIndex:i - 101];
            UIButton *button = [self.view viewWithTag:i];
            [button setImage:[UIImage imageNamed:identifier] forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidLayoutSubviews {
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"%f", screenHeight);
    UIImageView* titleImageView = [self.view viewWithTag:100];
    CGRect rect = titleImageView.frame;
    
    if (screenHeight > 568) {
        [titleImageView setFrame:CGRectMake(rect.origin.x, rect.origin.y + 20, rect.size.width, rect.size.height)];
        
        for (int i = 101; i <= 112; i ++) {
            UIButton *button = [self.view viewWithTag:i];
            CGRect rect = button.frame;
            [button setFrame:CGRectMake(rect.origin.x, rect.origin.y + 40, rect.size.width, rect.size.height)];
        }
    }
    else if (screenHeight == 568) {
        [titleImageView setFrame:CGRectMake(rect.origin.x, rect.origin.y + 10, rect.size.width, rect.size.height)];
        
        for (int i = 101; i <= 112; i ++) {
            UIButton *button = [self.view viewWithTag:i];
            CGRect rect = button.frame;
            [button setFrame:CGRectMake(rect.origin.x, rect.origin.y + 10, rect.size.width, rect.size.height)];
        }
    }
    else {
        [titleImageView setFrame:CGRectMake(rect.origin.x, rect.origin.y - 30, rect.size.width, rect.size.height)];
        
        for (int i = 101; i <= 112; i ++) {
            UIButton *button = [self.view viewWithTag:i];
            CGRect rect = button.frame;
            [button setFrame:CGRectMake(rect.origin.x, rect.origin.y - 50, rect.size.width, rect.size.height)];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onMailBut:(id)sender {
    
    UIButton *button = sender;
    int tag = (int)button.tag;
    NSString *identifier =  [ArrayCSV objectAtIndex:tag - 101];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL emailVerified = [prefs boolForKey:EMAIL_VERIFIED];
    if (emailVerified) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"wordlist"];
        [AppDelegate sharedAppDelegate].strCSV = identifier;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"subscribe"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [AppDelegate sharedAppDelegate].strCSV = segue.identifier;
    
    if ([segue.identifier isEqualToString:@"rss"]) {
        [_activityIndicator startAnimating];
    }
}


@end
