//
//  keychainWrapper.m
//  HelloOkta
//
//  Created by Nisola Shobayo on 6/26/15.
//  Copyright (c) 2015 Nisola Shobayo. All rights reserved.
// For more information about ios Keychain see: http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html

#import "KeychainUtils.h"

@implementation KeychainUtils : NSObject

NSString *serviceAttribute = @"helloOkta";
NSString *accountAttribute = @"exampleUser";
NSString *genericAttribure = @"helloOkta";

/*Initialize Keys for keychain Item storage */
- (NSMutableDictionary *)keychainInit{
    // Initializing keychain
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrService]= serviceAttribute;
    keychainItem[(__bridge id)kSecAttrAccount] = accountAttribute;
    keychainItem[(__bridge id)kSecAttrGeneric] = genericAttribure;
    
    return keychainItem;
}

/* Adds Item to keychain*/
- (void)addKeychainItem:(NSData *)data dictionary:(NSMutableDictionary *)keychainItem{
    keychainItem[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

/* Update value of specified keychain item */
- (void)updateKeychainItem:(NSData *)data dictionary:(NSMutableDictionary *)keychainItem{
    NSDictionary *oldKeychain = keychainItem;
    keychainItem[(__bridge id)kSecValueData] = data;
    SecItemUpdate((__bridge CFDictionaryRef)oldKeychain ,(__bridge CFDictionaryRef)keychainItem);
}

/* Delete keychain item */
- (void)deleteKeychainItem:(NSMutableDictionary *)keychainItem{
    SecItemDelete((__bridge CFDictionaryRef)(keychainItem));
}

/* Get value associated with keychain item  */
- (OSStatus *)getKeychainItem:(CFTypeRef *)result dictionary:(NSMutableDictionary *)keychainItem{
    if (result != nil) {
        keychainItem[(__bridge id)kSecReturnData] = (__bridge id)(kCFBooleanTrue);
    }
   return (OSStatus *)(long)SecItemCopyMatching((__bridge CFDictionaryRef)(keychainItem), result);
}


@end