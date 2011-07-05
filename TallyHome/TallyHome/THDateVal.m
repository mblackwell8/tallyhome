#import "THDateVal.h"


// per http://stackoverflow.com/questions/2736762/initializing-a-readonly-property

@interface THDateVal ()

@property (readwrite, retain) NSDate *date;
@property (readwrite) double val;


@end

@implementation THDateVal


@synthesize date = _date, val;

- (id) init {
    if ((self = [super init])) {
    }
    
    return self;
}

- (id) initWithVal:(double)v at:(NSDate *)dt {
    if ((self = [self init])) {
        self.val = v;
        self.date = dt;
    }
    
    return self;
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
        _date = nil;
    }
    
    [super dealloc];
}

@end