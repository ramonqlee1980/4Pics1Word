//
//  Utility.h
//  4Imgs1Word
//
//  Created by Ramonqlee on 1/6/14.
//  Copyright (c) 2014 idreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>
#include <CommonCrypto/CommonDigest.h>


@interface Utility : NSObject {
    
}
+ (NSString *) md5:(NSString *)str;
+ (NSString *) doCipher:(NSString *)sTextIn key:(NSString *)sKey context:(CCOperation)encryptOrDecrypt;
+ (NSString *) encryptStr:(NSString *) str;
+ (NSString *) decryptStr:(NSString *) str;


#pragma mark Based64
+ (NSString *) encodeBase64WithString:(NSString *)strData;
+ (NSString *) encodeBase64WithData:(NSData *)objData;
+ (NSData *) decodeBase64WithString:(NSString *)strBase64;

@end
