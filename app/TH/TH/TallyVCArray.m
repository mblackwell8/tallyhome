//
//  TallyVCArray.m
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyVCArray.h"
#import "DebugMacros.h"

@implementation TallyVCArray

@synthesize detailControllers = _tallyViewDetailControllers;


static NSString *_uuid;

// pasted from http://blog.ablepear.com/2010/09/creating-guid-or-uuid-in-objective-c.html
// return a new autoreleased UUID string
+ (NSString *)generateUuidString {
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    [uuidString autorelease];
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSString *)uniqueUserId {
    if (!_uuid) {
        _uuid = [[TallyVCArray generateUuidString] retain];
    }
    
    return _uuid;
}


- (id)init {
    self = [super init];
    if (self) {
        _tallyViewDetailControllers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark NSCoding

#define kTallyViewDetailCtrlrs    @"TVDetailCtrlrs"
#define kUUID                     @"UUID"


- (void)encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding RootViewController");
    [encoder encodeObject:_tallyViewDetailControllers forKey:kTallyViewDetailCtrlrs];
    [encoder encodeObject:_uuid forKey:kUUID];
}

// FUCK: as soon as I provide initWithCoder, the framework (?) calls this
// initializer rather than something else, and so the navigationController is not set
- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) {
        DLog(@"Decoding RootViewController");
        if (!(_tallyViewDetailControllers = [[decoder decodeObjectForKey:kTallyViewDetailCtrlrs] retain])) {
            _tallyViewDetailControllers = nil;
        }
        if (!(_uuid = [[decoder decodeObjectForKey:kUUID] retain])) {
            _uuid = [[TallyVCArray generateUuidString] retain];
        }
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [_tallyViewDetailControllers release];
}

- (void)addObject:(id)anObject {
    [_tallyViewDetailControllers addObject:anObject];
}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [_tallyViewDetailControllers insertObject:anObject atIndex:index];
}

- (NSUInteger)count {
    return _tallyViewDetailControllers.count;
}
- (id)lastObject {
    return  [_tallyViewDetailControllers lastObject];
}
- (id)objectAtIndex:(NSUInteger)index {
    return [_tallyViewDetailControllers objectAtIndex:index];
}

- (NSEnumerator *)dailyEnumerator {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}
- (NSEnumerator *)dailyEnumeratorStartingAt:(NSDate *)date {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [_tallyViewDetailControllers countByEnumeratingWithState:state objects:stackbuf count:len];
}


@end
