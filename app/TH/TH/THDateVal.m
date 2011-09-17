#import "THDateVal.h"


// per http://stackoverflow.com/questions/2736762/initializing-a-readonly-property

@interface THDateVal ()

@property (readwrite, retain, nonatomic) NSDate *date;
@property (readwrite, assign) double val;

@end

@implementation THDateVal


@synthesize date = _date, val, ix = _ix, last = _last, next = _next;

- (id)init {
    if ((self = [super init])) {
        _date = nil;
        _ix = nil;
        _last = nil;
        _next = nil;
        val = 0;
    }
    
    return self;
}

- (id)initWithVal:(double)v at:(NSDate *)dt {
    NSAssert(dt, @"date should not be nil");
    if ((self = [self init])) {
        val = v;
        _date = [dt retain];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    THDateVal *copy = [[THDateVal allocWithZone:zone] initWithVal:self.val at:self.date];
    //don't copy first, last or ix... these are mutable
    return copy;
}

#define kDateEncodeKey  @"Date"
#define kValueEncodeKey @"Value"

- (id)initWithCoder:(NSCoder *)decoder {
    NSDate *dt = [decoder decodeObjectForKey:kDateEncodeKey];
    double v = [decoder decodeDoubleForKey:kValueEncodeKey];
    
    return [self initWithVal:v at:dt];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_date forKey:kDateEncodeKey];
    [coder encodeDouble:val forKey:kValueEncodeKey];
}

- (NSComparisonResult)compareByDate:(THDateVal *)another {
    //if another is null or has a null date, this event is considered later
    if (!another || !(another.date))
        return NSOrderedDescending;
    
    return [_date compare:another.date];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: val=%5.2f", _date, val];
}

- (void)dealloc {
    if (_date) {
        [_date release];
    }
    
    [super dealloc];
}

- (BOOL)isEqual:(id)other{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToDateVal:other];
}

- (BOOL)isEqualToDateVal:(THDateVal *)other {
    if (self == other)
        return YES;
    //5 sig digits on valu
    if (round(val * 10e5) != round(other.val * 10e5))
        return NO;
    if (![_date isEqualToDate:other.date])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    int prime = 31;
    NSUInteger result = 1;
    
    //5 sig digits on val
    result = prime * result + round(val * 10e5);
    result = prime * result + [_date hash];
    
    return result;
}

@end