//
//  SharedUserDefaults.m
//  IOSToDoApp
//
//  Created by Salma on 19/04/2024.
//

#import "SharedUserDefaults.h"

@implementation SharedUserDefaults

+ (NSUserDefaults *)sharedUserDefaults {
    static NSUserDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NSUserDefaults standardUserDefaults];
    });
    return sharedInstance;
}

@end

