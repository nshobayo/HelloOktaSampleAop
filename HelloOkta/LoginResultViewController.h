//
//  LoginResultViewController.h
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/11/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (void)getUserInfo;
- (void)tableViewPopulate:(NSMutableDictionary *)userInfo;
- (void)addInfo:(NSString *)infoTitle info:(NSString *)info;
@property (nonatomic,retain)NSMutableDictionary *userItem;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (nonatomic,retain) NSURLConnection *renewConnection;
@property (nonatomic,retain) NSURLConnection *userInfoConnection;

@end
