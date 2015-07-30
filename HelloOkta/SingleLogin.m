//
//  SingleLogin.m
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved
//

#import "SingleLogin.h"
#import "LoginFlow.h"
#import "globals.h"

@interface SingleLogin ()

@end

@implementation SingleLogin
@synthesize org;
NSURLConnection *orgConnection;
NSString *flowUrl;

- (void) viewDidLoad {
    [super viewDidLoad];
}

/* On SSO login click*/
- (IBAction) ssoLogin:(id)sender {
    // Gets org name from text input field
    NSString *orgName = org.text;
    UILabel *msgLabel  =  (UILabel *)[self.view viewWithTag:100];

    // Check if field is empty, if get display error else send the org
    if ([orgName isEqualToString:@""]) {
        msgLabel.text = NSLocalizedString( @"Please enter your Okta org", nil);
    }
    else {
        // Send okta org name to request
        [self sendOrg];
    }
}

- (void) sendOrg {
    // Create request to send Okta org and retrieve desired WebView endpoint
    NSString *orgName = org.text;
    NSString *postTargetUrl = [NSMutableString stringWithFormat:@"%@%@%@", BASE_URL, @"/saml/login?tenant=", orgName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postTargetUrl]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 30.0;
    
    // Create url connection and fire request
    orgConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/* If response was received */
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Response from org GET request
    NSError *error = nil;
    UILabel *msgLabel = (UILabel *)[self.view viewWithTag:100];
    NSMutableDictionary *loginFlowData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];

    if( error == nil){
        // Retrieves the desired WebView URL from the response and passes it to next view
        flowUrl = [loginFlowData objectForKey:@"tenantUrl"];
        LoginFlow *loginFlow = [[LoginFlow alloc] init];
        loginFlow.orgInfo = flowUrl;
        msgLabel.text = @"";
        [self.navigationController pushViewController:loginFlow animated:YES];
    }
    else{
        msgLabel.text = NSLocalizedString([loginFlowData objectForKey:@"error"], nil);
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
