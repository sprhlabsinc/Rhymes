//
//  SubscribeViewController.m
//  Rhymes
//
//  Created by Akira on 5/14/17.
//  Copyright © 2017 mypc. All rights reserved.
//

#import "SubscribeViewController.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "Reachability.h"

@interface SubscribeViewController () <UITextFieldDelegate, UIWebViewDelegate>
- (IBAction)onCloseBut:(id)sender;
- (IBAction)onUnlockBut:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtUnlockEmail;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //[_txtEmail setText:[prefs objectForKey:EMAIL]];
    //[_txtUnlockEmail setText:[prefs objectForKey:EMAIL]];
    
    NSURL *url = [NSURL URLWithString:@"https://my.sendinblue.com/users/subscribe/js_id/2o9t0/id/2"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator stopAnimating];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    //[self.view setFrame:CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height)];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    //[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    return YES;
}

- (IBAction)onCloseBut:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onUnlockBut:(id)sender {
    
    if (![self validateEmail:_txtUnlockEmail.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Please input valid email address." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
    
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus != NotReachable) {
            
            NSString *urlPath = [NSString stringWithFormat:@"http://166.62.93.249/~findavendor2/admin/checkemail.php?email=%@", _txtUnlockEmail.text];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlPath]];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
            HUD.textLabel.text = @"Checking Email address verified";
            [HUD showInView:self.view];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                NSDictionary *jsonDict= [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions error:&error];
                NSString *code = [jsonDict objectForKey:@"code"];
                
                [NSOperationQueue.mainQueue addOperationWithBlock:^{
                    
                    if ([code isEqualToString:@"failure"]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Email address not verified." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        [alert addAction:action];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        NSDictionary *dict = [jsonDict objectForKey:@"data"];
                        dict = [dict objectForKey:@"attributes"];
                        NSString *v = [dict objectForKey:@"DOUBLE_OPT-IN"];
                        
                        if (v.intValue > 1) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Email address not verified." preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                            [alert addAction:action];
                            [self presentViewController:alert animated:YES completion:nil];
                        } else {
                        
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            [prefs setBool:true forKey:EMAIL_VERIFIED];
                            [prefs synchronize];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }
                    [HUD dismiss];
                }];
                
            }] resume];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"There is no internet connection." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}


@end
