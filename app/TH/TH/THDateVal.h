#import <Foundation/Foundation.h>

@class THTimeSeries;

@interface THDateVal : NSObject <NSCoding, NSCopying> {
    NSDate *_date;
    double val;
    THTimeSeries *_ix; //weak ref
    THDateVal *_last, *_next; //weak refs
}

@property (readonly, retain, nonatomic) NSDate* date;
@property (readonly, assign) double val;
@property (assign, nonatomic) THTimeSeries *ix;
@property (assign, nonatomic) THDateVal *last;
@property (assign, nonatomic) THDateVal *next;

- (id)initWithVal:(double)v at:(NSDate *)dt;
- (id)copyWithZone:(NSZone *)zone;
- (NSComparisonResult)compareByDate:(THDateVal *)another;

- (NSString *)description;

- (void)dealloc;

- (BOOL)isEqual:(id)anObject;
- (BOOL)isEqualToDateVal:(THDateVal *)dateVal;
- (NSUInteger)hash;

@end