//
//  LoginViewController.m
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import "LoginViewController.h"
#import "globals.h"

@interface LoginViewController ()
@end

@implementation LoginViewController

@synthesize username;
@synthesize password;
NSMutableData *responseData;
NSURLConnection *oauthConnection;
NSString *clientId= @"demopass";
NSMutableDictionary *userKeychain;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Create a keychain manager object
    keychainUtils = [KeychainUtils alloc];
    userKeychain = [keychainUtils keychainInit];
    
    // Check if keychain item already exists
    if ([keychainUtils getKeychainItem:nil dictionary:userKeychain] == noErr) {
        //redirect user to successful login page
        [self performSegueWithIdentifier:@"successLogin" sender:nil];
    }
}

/* Activated if login button is pressed */
- (IBAction) loginSubmit:(UIButton *)sender {
    UILabel *msgLabel = (UILabel *)[self.view viewWithTag:100];
    
    // Check user input
    if ([username.text isEqualToString:@""] && [password.text isEqualToString:@""]) {
        // Display message that content for both must be entered
        msgLabel.text = NSLocalizedString(@"Please enter your credentials", @"no credentials");
    }
    else if ([username.text  isEqualToString:@""]) {
        // Add a massage with nothing entered
        msgLabel.text = NSLocalizedString(@"Please enter your username", @"empty username");
    }
    else if ([password.text isEqualToString:@""]) {
        // Add a message saying no pass entered
        msgLabel.text = NSLocalizedString(@"Please enter your password", @"empty password");
    }
    else {
        // Construct POST request to retrieve OAuth token via credentials
        NSString *requestUrl = [NSString stringWithFormat:@"%@%@", BASE_URL, @"/oauth2/token?"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
        // Create HTTP POST Body
        NSString *post = [NSString stringWithFormat:@"grant_type=password&client_id=%@&username=%@&password=%@", clientId, [username.text lowercaseString], password.text];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        request.HTTPMethod = @"POST";
        request.HTTPBody = postData;
        request.timeoutInterval = 30.0;
    
        // Create url connection and fire request
        oauthConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

/* If response was received */
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    UILabel *msgLabel = (UILabel *)[self.view viewWithTag:100];
    NSError *error = nil;
    
    // Serializes response data into a JSON formatted Dictionary
    NSMutableDictionary *jsonArray = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    if(connection == oauthConnection) {
        // Check if credentials entered were invalid credentials
        if ([jsonArray objectForKey:@"error"] != nil) {
            msgLabel.text = NSLocalizedString([jsonArray objectForKey:@"error"], nil);
            password.text = NSLocalizedString(@"", nil);
        }
        else {
            msgLabel.text = NSLocalizedString(@"", nil);
            password.text = NSLocalizedString(@"", nil);
            username.text = NSLocalizedString(@"", nil);
    
            // Store Timestamp into keychain
            [jsonArray setObject:[[NSDate date] description] forKey:@"time_created"] ;
            NSString *tokens = [jsonArray description];
      
            // Add userData to keychain then transition into resultView view
            [keychainUtils addKeychainItem:[tokens dataUsingEncoding:NSUTF8StringEncoding] dictionary:userKeychain];
            [self performSegueWithIdentifier:@"successLogin" sender:nil];
        }
    }
}

- (void) didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
}

@end
