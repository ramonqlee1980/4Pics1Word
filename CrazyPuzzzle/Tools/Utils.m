//
//  Utils.m
//  CrazyPuzzzle
//
//  Created by Ramonqlee on 12/1/13.
//  Copyright (c) 2013 xiaoran. All rights reserved.
//

#import "Utils.h"
#import "RMQuestionsRequest.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

#define CurrentGoldenStringKey @"CurrentGolden"
#define kDailyChallengeDateKey @"DailyChallengeDateKey"

static NSString* ipAddress;
@implementation Utils

// Get IP Address
+ (NSString *)getIPAddress {
    if (ipAddress && ipAddress.length>0) {
        return ipAddress;
    }
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] hasPrefix:@"en"]) {
                    // Get NSString from C String
                    ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return ipAddress;
}
+ (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(void)removeSubviews:(UIView*)view
{
    if (view) {
        NSArray* array = [view subviews];
        for (UIView* t in array) {
            if (t) {
                [t removeFromSuperview];
            }
        }
    }
}

+ (id)objectForKey:(NSString *)defaultName
{
    return [USER_DEFAULT objectForKey:defaultName];
}
+(void)setValue:(id)value forKey:(NSString *)defaultName
{
    [USER_DEFAULT setValue:value forKey:defaultName];
    [USER_DEFAULT synchronize];
}

+(NSUInteger)currentCoins
{
    id value = [Utils objectForKey:CurrentGoldenStringKey];
    
    if(value){
        return [value intValue];
    }
    
    [Utils setValue:[NSNumber numberWithInt:CP_Initial_Golden] forKey:CurrentGoldenStringKey];
    return CP_Initial_Golden;
}
+(void)setCurrentCoins:(NSInteger)coins
{
    [Utils setValue:[NSNumber numberWithInt:coins] forKey:CurrentGoldenStringKey];
}

#pragma mark level setting
+(NSUInteger)level:(NSString*)name
{
    id value = [Utils objectForKey:name];
    
    if(value){
        return [value intValue];
    }
    
    [Utils setValue:[NSNumber numberWithInt:CP_Initial_Level_FROM_ZERO] forKey:name];
    return CP_Initial_Level_FROM_ZERO;
}

+(void)setLevel:(NSInteger)level  forCategory:(NSString*)name
{
    [Utils setValue:[NSNumber numberWithInt:level] forKey:name];
}

#pragma mark daily challenge setting
+(void)setDailyChallengeOff
{
    [Utils setValue:[Utils today] forKey:kDailyChallengeDateKey];
}
+(BOOL)dailyChallengeOn
{
    return ![[Utils today] isEqualToString:[Utils objectForKey:kDailyChallengeDateKey]];
}
+(NSString*)today
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [outputFormatter stringFromDate:[NSDate date]];
    NSLog(@"testDate:%@", str);
    return str;
}

//关卡相关
+(void)unlockCategory:(NSString*)levelName
{
    [Utils setValue:levelName forKey:levelName];
}
-(BOOL)categoryUnlocked:(NSString*)levelName
{
    return [levelName isEqualToString:[Utils objectForKey:levelName]];
}
@end
