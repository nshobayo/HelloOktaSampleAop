//
//  LoginFlow.m
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/22/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import "LoginFlow.h"
#import "LoginResultViewController.h"
#import "globals.h"
@interface LoginFlow ()

@end

@implementation LoginFlow
NSString *orgInfo;
NSURLConnection *webviewConnection;
NSMutableDictionary *userItem;

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Login";
    
    // Create keychain manager
    keychainUtils = [KeychainUtils alloc];
    userItem = [keychainUtils keychainInit];

    // Create and load WebView
    [self loadUIWebView];
}

/* create and load a fullscreen WebView */
- (void)loadUIWebView{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_orgInfo]]];
    [webView setDelegate:self];
    [self.view addSubview:webView];
}

/* WebView calls on view with HTTP request */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = request.URL;
    NSURL *initURl = [NSURL URLWithString:_orgInfo];
    
    // Stops request from loading by returning NO if the request corresponds to final sign-on destination
    if([url.absoluteString containsString:initURl.host] && [url.absoluteString containsString:@"sso"]){
        // Recreates request to get OAuth token from HTTP POST response
        webviewConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        return NO;
    }
    return YES;
}

/* Called if data is retrieved after HTTP request*/
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection == webviewConnection){
    NSError *error = nil;
    NSMutableDictionary *jsonArray;
    
        // Serializes response data into a JSON formatted Dictionary
        jsonArray = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    
        // Check if credentials entered were invalid
        if ([jsonArray objectForKey:@"error"] != nil) {
            //should not happen
        }
        else {
            // Parse JSON for OAuth
            [jsonArray setObject:[[NSDate date] description] forKey:@"time_created"] ;
            NSString *tokens = [jsonArray description];
        
            // Add authentication token to keychain
            [keychainUtils addKeychainItem:[tokens dataUsingEncoding:NSUTF8StringEncoding] dictionary:userItem];
            
            //Segues into result view - there are more straightforward ways to transition but they seemed buggy when used tangental to the WebView
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginResultViewController *loginResult = [storyBoard instantiateViewControllerWithIdentifier:@"result"];
            [self.navigationController pushViewController:loginResult animated:YES];
        }
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
