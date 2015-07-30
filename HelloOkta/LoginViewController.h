//
//  LoginViewController.h
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic,retain)NSMutableDictionary *keychainItem;
@property (weak, nonatomic) IBOutlet UIButton *loginSubmit;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (nonatomic,retain) NSURLConnection *firstConnection;


@end
