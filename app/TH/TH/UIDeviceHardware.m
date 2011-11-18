//
//  UIDeviceHardware.m
//
//  Used to determine EXACT version of device software is running on.

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDeviceHardware

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)platformString {
    NSString *platform = [UIDeviceHardware platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+ (double)processorSpeedInMhz {
    NSString *platform = [UIDeviceHardware platform];
    if ([platform isEqualToString:@"iPhone1,1"])
        return 412;    
    if ([platform isEqualToString:@"iPhone1,2"])
        return 412;
    if ([platform isEqualToString:@"iPhone2,1"])
        return 600;
    if ([platform isEqualToString:@"iPhone3,1"])
        return 800;    
    if ([platform isEqualToString:@"iPhone3,3"])
        return 800;
    if ([platform isEqualToString:@"iPhone4,1"])
        return 800;
    
    
    if ([platform isEqualToString:@"iPod1,1"])
        return 412; //don't know... same as iPhone?
    if ([platform isEqualToString:@"iPod2,1"])
        return 412; //don't know
    if ([platform isEqualToString:@"iPod3,1"])
        return 600; //don't know... 3GS internal apparently
    if ([platform isEqualToString:@"iPod4,1"])
        return 800;
    
    
    if ([platform isEqualToString:@"iPad1,1"])
        return 1000;
    if ([platform isEqualToString:@"iPad2,1"])
        return 1000;
    if ([platform isEqualToString:@"iPad2,2"])
        return 1000;
    if ([platform isEqualToString:@"iPad2,3"])
        return 1000;

    
    //clearly these vary... just make very high
    if ([platform isEqualToString:@"i386"])
        return 2000;
    if ([platform isEqualToString:@"x86_64"])
        return 2000;
    
    return 500; //default to something...
}

+ (BOOL)hasRetinaDisplay {
    NSString *platform = [UIDeviceHardware platform];
    if ([platform isEqualToString:@"iPhone1,1"])
        return NO;    
    if ([platform isEqualToString:@"iPhone1,2"])
        return NO;
    if ([platform isEqualToString:@"iPhone2,1"])
        return NO;
    if ([platform isEqualToString:@"iPod1,1"])
        return NO;
    if ([platform isEqualToString:@"iPod2,1"])
        return NO;
    if ([platform isEqualToString:@"iPod3,1"])
        return NO;
    if ([platform isEqualToString:@"iPad1,1"])
        return NO;
    if ([platform isEqualToString:@"i386"])
        return NO;
    if ([platform isEqualToString:@"x86_64"])
        return NO;
    
    return YES;
}

//- (BOOL)hasMultitasking {
//    if ([self respondsToSelector:@selector(isMultitaskingSupported)]) {
//        return [self isMultitaskingSupported];
//    }
//    return NO;
//}
//
//- (BOOL)hasCamera {
//    BOOL ret = NO;
//    // check camera availability
//    return ret;
//}


@end