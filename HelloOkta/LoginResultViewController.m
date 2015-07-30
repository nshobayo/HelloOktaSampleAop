//
//  LoginResultViewController.m
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import "LoginResultViewController.h"
#import "globals.h"

@interface LoginResultViewController ()

@end

@implementation LoginResultViewController
NSMutableArray *cells;
NSURLConnection *renewConnection;
NSURLConnection *userInfoConnection;
NSMutableDictionary *userInfo;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initializes array containing table view items
    cells = [[NSMutableArray alloc] init];
    self.navigationItem.hidesBackButton = YES;
    
    //create keychain manager
    keychainUtils = [KeychainUtils alloc] ;
    userInfo = [keychainUtils keychainInit];
    
    /* Tries to get the user info, if failed due to invalid keychain data,
      keychain item is deleted and user is sent back to first screen */
    @try {
        [self getUserInfo];
    }
    @catch(NSException *exception){
        if ( [exception isEqual:@"NSParseErrorException"]){
            [keychainUtils deleteKeychainItem:userInfo];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            @throw exception;
        }
    }
}

/* Returns proper cell corresponding to index path element */
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    //Returns cells with row corresponding to index in cell array 'cells'
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    cell.textLabel.text = NSLocalizedString([cells objectAtIndex:indexPath.row], nil);
    return cell;
}

/* TableView delegate to indicate number of rows in each table column */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cells count];
}

/* Queries for User Information */
- (void) getUserInfo {
    // Get saved data from the IOS keychain
    CFTypeRef result;
    [keychainUtils getKeychainItem:&result dictionary:userInfo];

    // Get data from the keychain item from as a dictionary object
    NSString *dataAsString = [[NSString alloc] initWithData:(__bridge NSData *)result encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataAsString);
    NSDictionary *tokens =  [dataAsString propertyList];

    NSTimeInterval tokenExpirationTime = [[tokens objectForKey:@"expires_in"] integerValue];
    // Convert keychain string into date
    NSDate *timeCreated = [self stringToDate:[tokens objectForKey:@"time_created"]];
    
    // Check if access token is expired, if so use the renew token, if not retrieve data using token.
    if ([timeCreated timeIntervalSinceNow] >= tokenExpirationTime) { 
        NSString *renewToken = [tokens objectForKey:@"renew_token"];
        [self useRenewToken:renewToken];
        [self getUserInfo];
    }
    else {
        // Use the token to get info
        NSString *accessToken = [tokens objectForKey:@"access_token"];
  
        // Construct an HTTP POST request
        NSString *requestUrl = [NSString stringWithFormat:@"%@%@", BASE_URL, @"/scim/v2/Users/Me?"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 30.0;
        [request setValue:[NSString stringWithFormat:@"%@ %@", @"Bearer", accessToken] forHTTPHeaderField:@"Authorization"];
    
        // Create URL connection and fire request
        userInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

/* Use renew token to send a retrieve new OAuth token */
- (void) useRenewToken:(NSString *)refreshToken {
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", BASE_URL, @"/oauth2/token?"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    // Construct an HTTP POST request
    NSString *post = [NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@&", refreshToken];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    request.timeoutInterval = 30.0;
    
    //Create url connection and fire request
    renewConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/* Data received  from post response */
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    
    if(connection == renewConnection){
        NSMutableDictionary *jsonArray = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
        // Parse json for authtoken
        [jsonArray setObject:[[NSDate date] description] forKey:@"time_created"] ;
        NSString *tokens = [jsonArray description];
        
        // Add authentication token to keychain
        [keychainUtils updateKeychainItem:[tokens dataUsingEncoding:NSUTF8StringEncoding] dictionary:userInfo];
        
    } else if(connection == userInfoConnection){
        // Use the info to display
        NSMutableDictionary *jsonArray = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
        [self tableViewPopulate:jsonArray];
    
        // Reload table view
        UITableView *tableView = (UITableView *)[self.view viewWithTag:50];
        [tableView reloadData];
    }
}

/* Populates the table with user data */
- (void) tableViewPopulate:(NSMutableDictionary *) userInfo {
    // Get user data from dictionary, type dictated by json format
    NSString *userName = [userInfo objectForKey:@"userName"];
    NSDictionary *nameContainer = [userInfo objectForKey:@"name"];
    NSArray *numberContainer = [userInfo objectForKey:@"phoneNumbers"];
    NSArray *emailContainer = [userInfo objectForKey:@"emails"];
    
    // Add extracted user info to cell contents
    [self addInfo:@"User Name" info:userName];
    [self parseDictionaryObject:nameContainer attributeName:@"Name"];
    [self parseListObject:emailContainer attributeName:@"Email"];
    [self parseListObject:numberContainer attributeName:@"Phone Number"];
}

/* Parses dictionary object of type [ { "string, string, ...}, ...] and adds them of contents */
- (void) parseListObject:(NSArray *)jsonContainer attributeName:(NSString *) attributeName {
    if ([jsonContainer count]>0) {
        NSArray *jsonArray = [jsonContainer valueForKey:@"value"];
        for (NSString *jsonElement in jsonArray) {
            [self addInfo:attributeName info:jsonElement];
        }
    }
}

/* Parses dictionary object of format { identifier :[ string, string, ...]. ...}   */
- (void) parseDictionaryObject:(NSDictionary *)jsonName attributeName:(NSString *) attributeName {
    if ([[jsonName allKeys] count] > 0) {
        NSString *attribute = [jsonName objectForKey:@"formatted"];
        [self addInfo:attributeName info:attribute];
    }
}

/* Convert string of format yyyy-MM-dd HH:mm:ss ZZZ to NSDate object */
- (NSDate *) stringToDate:(NSString *)stringTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    return [dateFormatter dateFromString:stringTime];
}

/* Adds formated string to cells array for use */
- (void) addInfo:(NSString *)infoTitle info:(NSString *)info {
    NSString *formattedString = [NSString stringWithFormat:@"%@: %@", infoTitle, info];
    [cells addObject:formattedString];
}

/* Log user out */
- (IBAction) logout:(UIButton *)sender {
    [keychainUtils deleteKeychainItem:userInfo];
    // Go to home logout view
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
