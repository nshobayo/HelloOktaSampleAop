//
//  SingleLogin.h
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleLogin : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *org;
@property (strong, nonatomic) IBOutlet UIButton *send;
@property (nonatomic,retain) NSURLConnection *orgConnection;

@end
