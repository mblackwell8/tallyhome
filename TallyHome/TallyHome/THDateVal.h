#import <Foundation/Foundation.h>

@interface THDateVal : NSObject <NSCoding>
{
    NSDate *_date;
    double val;
}

@property (readonly, retain) NSDate* date;
@property (readonly) double val;

- (id) initWithVal:(double)v at:(NSDate *)dt;

- (NSComparisonResult)compareByDate:(THDateVal *)another;

- (NSString *)description;

- (void)dealloc;

@end