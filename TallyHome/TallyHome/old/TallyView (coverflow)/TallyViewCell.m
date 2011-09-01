//
//  TallyViewCell.m
//  TallyHome
//
//  Created by Mark Blackwell on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyViewCell.h"
#import "DebugMacros.h"
#import "THDate.h"
#import "TallyHomeConstants.h"

@interface TallyViewCellSummary : CALayer {
    NSString *_label;
    UIFont *_labelFont;
}

@property (copy, nonatomic) NSString *label;

- (void)drawInContext:(CGContextRef)ctx;

@end

@interface TallyViewCellDetail : CALayer {
    NSString *_dateLabel;
    NSString *_valueLabel;
    NSString *_commentLabel;
    
    UIFont *_dateFont;
    UIFont *_valueFont;
    UIFont *_commentFont;
}

@property (copy, nonatomic) NSString *dateLabel, *valueLabel;

- (void)drawInContext:(CGContextRef)ctx;

@end


@implementation TallyViewCell

static NSNumberFormatter *normalValueLblFormatter;
static NSNumberFormatter *middleValueLblFormatter; // has extra decimal places see setRoundingIncrement

//setData has custom implementation below
@synthesize data = _data, summary = _summary, detail = _detail, number = _number;

- (void)setData:(THDateVal *)data {
    [_data release];
    _data = [data copy];
    
    [_dateLabel release];
    _dateLabel = [[_data.date fuzzyRelativeDateString] retain];
    
    [_valueLabel release];
    _valueLabel = [[normalValueLblFormatter stringFromNumber:[NSNumber numberWithDouble:data.val]] retain];
    
}

+ (void) initialize {
    
    normalValueLblFormatter = [[NSNumberFormatter alloc] init];
    [normalValueLblFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [normalValueLblFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [normalValueLblFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
    
    //HACK: this seems to work, but looks inappropriate... may not localize
    [normalValueLblFormatter setMaximumFractionDigits:0];
    
    middleValueLblFormatter = [[NSNumberFormatter alloc] init]; 
    [middleValueLblFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [middleValueLblFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [middleValueLblFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:0.01]];
    
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dateFont = [[UIFont fontWithName:@"Helvetica" size:12.0] retain];
        _valueFont = [[UIFont fontWithName:@"Helvetica" size:22.0] retain];
        _commentFont = [[UIFont fontWithName:@"Helvetica" size:10.0] retain];
        
//        _summary = [self createSummaryLayer];
//        [self.layer addSublayer:_summary];
//        self.summary = _summary;
//        
//        _detail = [self createDetailLayer];
//        [self.layer addSublayer:_detail];
//        self.detail = _detail;
        
        _number = 0;
    }
    return self;
}

//+ (Class)layerClass {
//    return [CATransformLayer class];
//}

- (void)dealloc {
    [_dateLabel release];
    [_valueLabel release];
    
    [_dateFont release];
    [_valueFont release];
    [_commentFont release];
    
    [_data release];
    
    [super dealloc];
}

//- (void)setNumber:(int)newNumber {
//	_verticalPosition = COVER_SPACING * newNumber;
//	_number = newNumber;
//}

- (void)setFrame:(CGRect)newFrame {
	[super setFrame:newFrame];
    
    // TODO: size the sublayers
}


- (CALayer *)createSummaryLayer {
    DLog(@"--create summary");
    
    CALayer *front = [[TallyViewCellSummary alloc] init];
    
    front.bounds = CGRectMake(0.0f, 0.0f, TH_TALLYVIEWCELL_DEFAULTWD, TH_TALLYVIEWCELL_DEFAULTHT);
    front.position = CGPointMake(0, 0);
    front.edgeAntialiasingMask = 0;
    front.backgroundColor = [[UIColor grayColor] CGColor];
    front.cornerRadius = 8;
    front.borderWidth = 1;
    front.borderColor = [[UIColor grayColor] CGColor];
    front.doubleSided = NO;
    
    return [front autorelease];
}

- (CALayer *)createDetailLayer {
    DLog(@"--create detail");
    
    CALayer *back = [[TallyViewCellDetail alloc] init];
    
    back.backgroundColor = [[UIColor blueColor] CGColor];
    back.contentsGravity = kCAGravityResize;
    back.masksToBounds = YES;
    back.borderWidth = 8;
    back.borderColor = [[UIColor grayColor] CGColor];;
    back.cornerRadius = 8;
    back.doubleSided = NO;
    
    back.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);

    return [back autorelease];
}


//HACK... trying to make work
- (void)drawRect:(CGRect)rect {
//    [_summary setNeedsDisplay];
//    [_detail setNeedsDisplay];
    [[UIColor redColor] setFill];
    UIRectFill(rect);
    
    [[UIColor blackColor] setStroke];
    UIRectFrame(rect);
    
    [[UIColor grayColor] setFill];
    NSString *numStr = [NSString stringWithFormat:@"Number %d", _number];
    [numStr drawAtPoint:CGPointMake(5.0, 5.0) withFont:_valueFont];
}

@end



@implementation TallyViewCellSummary

@synthesize label = _label;

- (id)init {
    self = [super init];
    if (self) {
        _labelFont = [[UIFont fontWithName:@"Helvetica" size:12.0] retain];
        self.opaque = YES;
    }
    return self;
}


- (void)drawInContext:(CGContextRef)ctx {
    DLog(@"drawing summary layer");
        
    CGFloat cornerRadius = self.frame.size.height * kDefaultTallyViewCellCornerRadiusHeight;
    
    CGRect borderRect = CGRectMake(kDefaultTallyViewCellBorderWidth / 2.0,
                                   kDefaultTallyViewCellBorderWidth / 2.0,
                                   self.frame.size.width - kDefaultTallyViewCellBorderWidth, 
                                   self.frame.size.height - kDefaultTallyViewCellBorderWidth);
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:cornerRadius];
    border.lineWidth = kDefaultTallyViewCellBorderWidth;
    
    
    
//    CGRect contentRect = CGRectMake(borderRect.origin.x + cornerRadius,
//                                    borderRect.origin .y /* + cornerRadius */,
//                                    borderRect.size.width - (cornerRadius * 2.0), 
//                                    borderRect.size.height /* - cornerRadius * 2.0 */);
//
//    //just draw date centred on grey background
//    
//    [[UIColor grayColor] setFill];
//    [border fill];
//    
//    [[UIColor blackColor] setFill];
//    
//    CGSize panningDtSize = [_label sizeWithFont:_labelFont 
//                                  constrainedToSize:contentRect.size 
//                                      lineBreakMode:UILineBreakModeTailTruncation];
//    //DLog(@"Panning dt sz w = %5.2f, h = %5.2f", panningDtSize.width, panningDtSize.height);
//    CGPoint panningDtPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - panningDtSize.width) / 2.0, 
//                                      contentRect.origin.y + (contentRect.size.height - panningDtSize.height) / 2.0);
//    [_label drawAtPoint:panningDtPt withFont:_labelFont];

}

@end

@implementation TallyViewCellDetail

@synthesize dateLabel = _dateLabel, valueLabel = _valueLabel;

- (id)init {
    self = [super init];
    if (self) {
        _dateFont = [[UIFont fontWithName:@"Helvetica" size:12.0] retain];
        _valueFont = [[UIFont fontWithName:@"Helvetica" size:22.0] retain];
        _commentFont = [[UIFont fontWithName:@"Helvetica" size:10.0] retain];
        
        self.opaque = YES;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    DLog(@"drawing detail layer");
    
//    // clear the context first
//    [[UIColor whiteColor] setFill];
//    UIRectFill(self.frame);
//    //    [[UIColor whiteColor] setStroke];
//    //    UIRectFrame(rect);
//    
//    CGFloat cornerRadius = self.frame.size.height * kDefaultTallyViewCellCornerRadiusHeight;
//    
//    CGRect borderRect = CGRectMake(kDefaultTallyViewCellBorderWidth / 2.0,
//                                   kDefaultTallyViewCellBorderWidth / 2.0,
//                                   self.frame.size.width - kDefaultTallyViewCellBorderWidth, 
//                                   self.frame.size.height - kDefaultTallyViewCellBorderWidth);
//    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:cornerRadius];
//    border.lineWidth = kDefaultTallyViewCellBorderWidth;
//    [[UIColor grayColor] setStroke];
//    [border stroke];
//    
//    CGRect contentRect = CGRectMake(borderRect.origin.x + cornerRadius,
//                                    borderRect.origin .y /* + cornerRadius */,
//                                    borderRect.size.width - (cornerRadius * 2.0), 
//                                    borderRect.size.height /* - cornerRadius * 2.0 */);    
//    
//    //draw the dateLabel at top left
//    CGFloat currY = contentRect.origin.y;
//    CGFloat currHeight = contentRect.size.height * kDefaultTallyViewCellDateLabelHeight;
//    CGRect dtBgrdRect = CGRectMake(borderRect.origin.x, borderRect.origin.y, 
//                                   borderRect.size.width, 
//                                   currHeight + (borderRect.size.height - contentRect.size.height) / 2.0);
//    UIBezierPath *dtBgrd = [UIBezierPath bezierPathWithRoundedRect:dtBgrdRect 
//                                                 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight 
//                                                       cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
//    [[UIColor grayColor] setFill];
//    [dtBgrd fill];
//    
//    [[UIColor blackColor] setFill];
//    //    CGSize dtMaxSize = CGSizeMake(contentRect.size.width, currHeight);
//    //    CGSize dtSize = [_dateLabel sizeWithFont:_dateFont 
//    //                             constrainedToSize:dtMaxSize 
//    //                                 lineBreakMode:UILineBreakModeTailTruncation];    
//    [_dateLabel drawAtPoint:contentRect.origin withFont:_dateFont];
//    
//    // draw the value, centred
//    currY += currHeight;
//    currHeight = contentRect.size.height * kDefaultTallyViewCellValueLabelHeight;
//    CGSize valMaxSize = CGSizeMake(contentRect.size.width, currHeight);
//    CGSize valSize = [_valueLabel sizeWithFont:_valueFont 
//                             constrainedToSize:valMaxSize 
//                                 lineBreakMode:UILineBreakModeTailTruncation];
//    CGPoint valPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - valSize.width) / 2.0, 
//                                currY + (currHeight - valSize.height) / 2.0);
//    [_valueLabel drawAtPoint:valPt withFont:_valueFont];
//    
//    
//    //draw the comment right aligned at bottom
//    currY += currHeight;
//    currHeight = contentRect.size.height * kDefaultTallyViewCellCommentLabelHeight;
//    
//    CGRect cmtBgrdRect = CGRectMake(borderRect.origin.x, borderRect.origin.y + (currY - contentRect.origin.y), 
//                                    borderRect.size.width, 
//                                    currHeight + (borderRect.size.height - contentRect.size.height) / 2.0);
//    UIBezierPath *cmtBgrd = [UIBezierPath bezierPathWithRoundedRect:cmtBgrdRect 
//                                                  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
//                                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
//    [[UIColor grayColor] setFill];
//    [cmtBgrd fill];
//    
//    [[UIColor blackColor] setFill];
//    CGSize commMaxSize = CGSizeMake(contentRect.size.width, currHeight);
//    CGSize commSize = [@"TODO" sizeWithFont:_commentFont 
//                          constrainedToSize:commMaxSize 
//                              lineBreakMode:UILineBreakModeTailTruncation];
//    CGPoint commPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - commSize.width), 
//                                 currY + (currHeight - commSize.height));
//    [@"TODO" drawAtPoint:commPt withFont:_commentFont];
    

}

@end