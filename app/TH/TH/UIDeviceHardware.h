//
//  UIDeviceHardware.h
//
//  Used to determine EXACT version of device software is running on.

//  see https://gist.github.com/1323251

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject 

+ (NSString *) platform;
+ (NSString *) platformString;
+ (double)processorSpeedInMhz;
+ (BOOL)hasRetinaDisplay;
//- (BOOL)hasMultitasking;
//- (BOOL)hasCamera;

@end