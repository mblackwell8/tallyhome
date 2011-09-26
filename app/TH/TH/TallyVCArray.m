//
//  TallyVCArray.m
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyVCArray.h"
#import "DebugMacros.h"

@class TallyDetailVC;

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

- (void)swapObjectAtIndex:(NSUInteger)i1 withObjectAtIndex:(NSUInteger)i2 {
    if (i1 == i2 || 
        i1 >= _tallyViewDetailControllers.count || 
        i2 >= _tallyViewDetailControllers.count )
        return;
    if (i1 > i2) {
        NSUInteger tmp = i2;
        i2 = i1;
        i1 = tmp;
    }
    
    NSAssert(i1 + 1 < _tallyViewDetailControllers.count, 
             @"if i1 != i2 and i2 < count, i1 + 1 s/be less than count");
    
    //remove the higher index object (i2)...
    id t2 = [[_tallyViewDetailControllers objectAtIndex:i2] retain];
    [_tallyViewDetailControllers removeObjectAtIndex:i2];
    
    //put it into the lower index spot...
    [_tallyViewDetailControllers insertObject:t2 atIndex:i1];
    
    //remove the lower index object, which will now be shuffled one space along
    id t1 = [[_tallyViewDetailControllers objectAtIndex:i1 + 1] retain];
    [_tallyViewDetailControllers removeObjectAtIndex:i1 + 1];
    
    //put it into the higher index spot
    [_tallyViewDetailControllers insertObject:t1 atIndex:i2];
    
    NSAssert([_tallyViewDetailControllers objectAtIndex:i2] == t1, @"should be true");
    NSAssert([_tallyViewDetailControllers objectAtIndex:i1] == t2, @"should be true");
    
    //really did not think it was necessary to retain then release within
    //a method call, but caused nasty mem bug without...
    [t2 release];
    [t1 release];
    
}

- (void)addObject:(id)anObject {
    [_tallyViewDetailControllers addObject:anObject];
}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [_tallyViewDetailControllers insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)ix {
    [_tallyViewDetailControllers removeObjectAtIndex:ix];
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
