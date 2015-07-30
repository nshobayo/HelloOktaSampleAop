//
//  keychainWrapper.h
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/26/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainUtils : NSObject
- (NSMutableDictionary *) keychainInit;
- (void) updateKeychainItem: (NSData *) data dictionary:(NSMutableDictionary *)keychainItem;
- (void) deleteKeychainItem:(NSMutableDictionary *)keychainItem;
- (void) addKeychainItem: (NSData *)data dictionary:(NSMutableDictionary *)keychainItem ;
- (OSStatus *) getKeychainItem:(CFTypeRef *)result dictionary:(NSMutableDictionary *)keychainItem;
@end