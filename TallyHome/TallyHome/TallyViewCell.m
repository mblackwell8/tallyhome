//
//  TallyViewCell.m
//  TallyHome
//
//  Created by Mark Blackwell on 21/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyViewCell.h"


@implementation TallyViewCell

static NSNumberFormatter *normalValueLblFormatter;
static NSNumberFormatter *middleValueLblFormatter; // has extra decimal places see setRoundingIncrement

//setData has custom implementation below
@synthesize isSummaryDisplayOnly = _isSummaryDisplayOnly, data = _data, number = _number;

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
        _dateFont = [[UIFont fontWithName:@"Helvetica" size:20.0] retain];
        _summaryDisplayDateFont = [[UIFont fontWithName:@"Helvetica" size:26.0] retain];
        _valueFont = [[UIFont fontWithName:@"Helvetica" size:36.0] retain];
        _commentFont = [[UIFont fontWithName:@"Helvetica" size:20.0] retain];
        _isSummaryDisplayOnly = YES;
        self.opaque = YES;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)dealloc {
    [_dateLabel release];
    [_valueLabel release];
    
    [_dateFont release];
    [_summaryDisplayDateFont release];
    [_valueFont release];
    [_commentFont release];
    
    [_data release];
    
    
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
#define kDefaultTallyViewCellDateLabelHeight 0.23
#define kDefaultTallyViewCellValueLabelHeight 0.54
#define kDefaultTallyViewCellCommentLabelHeight 0.23
#define kDefaultTallyViewCellBorderWidth 2.0
#define kDefaultTallyViewCellCornerRadiusHeight 0.10
    
    DLog(@"called for rect %@", NSStringFromCGRect(rect));
    
    if (rect.size.width != floor(self.frame.size.width))
        DLog(@"Mismatched expectations: rect width %5.3f, frame width %5.3f", rect.size.width, self.frame.size.width);
    
    // clear the context first
    [TH_TALLYVIEW_BACK_COLOR setFill];
    UIRectFill(rect);
    //    [[UIColor whiteColor] setStroke];
    //    UIRectFrame(rect);
    
    CGFloat cornerRadius = self.frame.size.height * kDefaultTallyViewCellCornerRadiusHeight;
    
    CGRect borderRect = CGRectMake(kDefaultTallyViewCellBorderWidth / 2.0,
                                   kDefaultTallyViewCellBorderWidth / 2.0,
                                   self.frame.size.width - kDefaultTallyViewCellBorderWidth, 
                                   self.frame.size.height - kDefaultTallyViewCellBorderWidth);
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:cornerRadius];
    border.lineWidth = kDefaultTallyViewCellBorderWidth;
    [TH_TALLYVIEWCELL_BACK_COLOR setStroke];
    [border stroke];
    
    CGRect contentRect = CGRectMake(borderRect.origin.x + cornerRadius,
                                    borderRect.origin .y /* + cornerRadius */,
                                    borderRect.size.width - (cornerRadius * 2.0), 
                                    borderRect.size.height /* - cornerRadius * 2.0 */);
    
    CGRect colorStripeRect = CGRectInset(borderRect, 4.0, 4.0);
    UIBezierPath *colorStripe = [UIBezierPath bezierPathWithRoundedRect:colorStripeRect cornerRadius:cornerRadius - 4.0];
    colorStripe.lineWidth = 3.0;
    [TH_TALLYVIEW_BACK_COLOR setStroke];
    [colorStripe stroke];
    
    if (_isSummaryDisplayOnly) {
        //just draw date centred on grey background
        
        [TH_TALLYVIEWCELL_BACK_COLOR setFill];
        [colorStripe fill];
        
        [[UIColor whiteColor] setFill];
        
        CGSize panningDtSize = [_dateLabel sizeWithFont:_summaryDisplayDateFont 
                                      constrainedToSize:contentRect.size 
                                          lineBreakMode:UILineBreakModeTailTruncation];
        //DLog(@"Panning dt sz w = %5.2f, h = %5.2f", panningDtSize.width, panningDtSize.height);
        CGPoint panningDtPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - panningDtSize.width) / 2.0, 
                                          contentRect.origin.y + (contentRect.size.height - panningDtSize.height) / 2.0);
        [_dateLabel drawAtPoint:panningDtPt withFont:_summaryDisplayDateFont];
        
        return;
    }
    
    [[UIColor whiteColor] setFill];
    UIRectFill(contentRect);
    
    //draw the dateLabel at top left
    CGFloat currY = contentRect.origin.y;
    CGFloat currHeight = contentRect.size.height * kDefaultTallyViewCellDateLabelHeight;
    CGRect dtBgrdRect = CGRectMake(borderRect.origin.x, borderRect.origin.y, 
                                   borderRect.size.width, 
                                   currHeight + (borderRect.size.height - contentRect.size.height) / 2.0);
    UIBezierPath *dtBgrd = [UIBezierPath bezierPathWithRoundedRect:dtBgrdRect 
                                                 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight 
                                                       cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    [TH_TALLYVIEWCELL_BACK_COLOR setFill];
    [dtBgrd fill];
    
    [[UIColor whiteColor] setFill];
    //    CGSize dtMaxSize = CGSizeMake(contentRect.size.width, currHeight);
    //    CGSize dtSize = [_dateLabel sizeWithFont:_dateFont 
    //                             constrainedToSize:dtMaxSize 
    //                                 lineBreakMode:UILineBreakModeTailTruncation];    
    [_dateLabel drawAtPoint:contentRect.origin withFont:_dateFont];
    
    // draw the value, centred
    currY += currHeight;
    currHeight = contentRect.size.height * kDefaultTallyViewCellValueLabelHeight;
    CGSize valMaxSize = CGSizeMake(contentRect.size.width, currHeight);
    CGSize valSize = [_valueLabel sizeWithFont:_valueFont 
                             constrainedToSize:valMaxSize 
                                 lineBreakMode:UILineBreakModeTailTruncation];
    CGPoint valPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - valSize.width) / 2.0, 
                                currY + (currHeight - valSize.height) / 2.0);
    [[UIColor blackColor] setFill];
    [_valueLabel drawAtPoint:valPt withFont:_valueFont];
    
    
    //draw the comment right aligned at bottom
    currY += currHeight;
    currHeight = contentRect.size.height * kDefaultTallyViewCellCommentLabelHeight;
    
    CGRect cmtBgrdRect = CGRectMake(borderRect.origin.x, borderRect.origin.y + (currY - contentRect.origin.y), 
                                    borderRect.size.width, 
                                    currHeight + (borderRect.size.height - contentRect.size.height) / 2.0);
    UIBezierPath *cmtBgrd = [UIBezierPath bezierPathWithRoundedRect:cmtBgrdRect 
                                                  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
                                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    [TH_TALLYVIEWCELL_BACK_COLOR setFill];
    [cmtBgrd fill];
    
    CGSize commMaxSize = CGSizeMake(contentRect.size.width, currHeight);
    CGSize commSize = [@"TODO" sizeWithFont:_commentFont 
                          constrainedToSize:commMaxSize 
                              lineBreakMode:UILineBreakModeTailTruncation];
    CGPoint commPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - commSize.width), 
                                 currY + (currHeight - commSize.height));
    [[UIColor whiteColor] setFill];
    [@"TODO" drawAtPoint:commPt withFont:_commentFont];
    
    
}



@end
