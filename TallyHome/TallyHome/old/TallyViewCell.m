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



@implementation TallyViewCell

static NSNumberFormatter *normalValueLblFormatter;
static NSNumberFormatter *middleValueLblFormatter; // has extra decimal places see setRoundingIncrement

//setData has custom implementation below
@synthesize isPanningFast = _isPanningFast, data = _data;

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
        _panningFastDateFont = [[UIFont fontWithName:@"Helvetica" size:22.0] retain];
        _valueFont = [[UIFont fontWithName:@"Helvetica" size:22.0] retain];
        _commentFont = [[UIFont fontWithName:@"Helvetica" size:10.0] retain];
        _isPanningFast = NO;
        self.opaque = YES;
    }
    return self;
}

- (void)dealloc {
    [_dateLabel release];
    [_valueLabel release];
    
    [_dateFont release];
    [_panningFastDateFont release];
    [_valueFont release];
    [_commentFont release];
    
    [_data release];
    
    
    
    [super dealloc];
}

- (void)scaleFontsBy:(CGFloat)scaleFactor {
    UIFont *newDtFont = [_dateFont fontWithSize:_dateFont.pointSize * scaleFactor];
    UIFont *newPanFastDtFont = [_panningFastDateFont fontWithSize:_panningFastDateFont.pointSize * scaleFactor];
    UIFont *newValFont = [_valueFont fontWithSize:_valueFont.pointSize * scaleFactor];
    UIFont *newCmtFont = [_commentFont fontWithSize:_commentFont.pointSize * scaleFactor];
    
    [_dateFont release];
    [_panningFastDateFont release];
    [_valueFont release];
    [_commentFont release];
    
    _dateFont = [newDtFont retain];
    _panningFastDateFont = [newPanFastDtFont retain];
    _valueFont = [newValFont retain];
    _commentFont = [newCmtFont retain];
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
#define kDefaultTallyViewCellDateLabelHeight 0.23
#define kDefaultTallyViewCellValueLabelHeight 0.54
#define kDefaultTallyViewCellCommentLabelHeight 0.23
#define kDefaultTallyViewCellBorderWidth 2.0
#define kDefaultTallyViewCellCornerRadiusHeight 0.10
    
    DLog(@"called");

    if (rect.size.width != floor(self.frame.size.width))
        DLog(@"Mismatched expectations: rect width %5.3f, frame width %5.3f", rect.size.width, self.frame.size.width);
    
    // clear the context first
    [[UIColor whiteColor] setFill];
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
    [[UIColor grayColor] setStroke];
    [border stroke];
    
    CGRect contentRect = CGRectMake(borderRect.origin.x + cornerRadius,
                                    borderRect.origin .y /* + cornerRadius */,
                                    borderRect.size.width - (cornerRadius * 2.0), 
                                    borderRect.size.height /* - cornerRadius * 2.0 */);
//    UIBezierPath *content = [UIBezierPath bezierPathWithRect:contentRect];
//    content.lineWidth = 1.0;
//    [[UIColor orangeColor] setStroke];
//    [content stroke];
    
    //DLog(@"Content rect sz w = %5.2f, h = %5.2f", contentRect.size.width, contentRect.size.height);
    
    if (_isPanningFast) {
        //just draw date centred on grey background
        
        [[UIColor grayColor] setFill];
        [border fill];
        
        [[UIColor blackColor] setFill];
        
        CGSize panningDtSize = [_dateLabel sizeWithFont:_panningFastDateFont 
                                 constrainedToSize:contentRect.size 
                                     lineBreakMode:UILineBreakModeTailTruncation];
        //DLog(@"Panning dt sz w = %5.2f, h = %5.2f", panningDtSize.width, panningDtSize.height);
        CGPoint panningDtPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - panningDtSize.width) / 2.0, 
                                          contentRect.origin.y + (contentRect.size.height - panningDtSize.height) / 2.0);
        [_dateLabel drawAtPoint:panningDtPt withFont:_panningFastDateFont];
        
        return;
    }
    
        
    //draw the dateLabel at top left
    CGFloat currY = contentRect.origin.y;
    CGFloat currHeight = contentRect.size.height * kDefaultTallyViewCellDateLabelHeight;
    CGRect dtBgrdRect = CGRectMake(borderRect.origin.x, borderRect.origin.y, 
                                   borderRect.size.width, 
                                   currHeight + (borderRect.size.height - contentRect.size.height) / 2.0);
    UIBezierPath *dtBgrd = [UIBezierPath bezierPathWithRoundedRect:dtBgrdRect 
                                                 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight 
                                                       cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    [[UIColor grayColor] setFill];
    [dtBgrd fill];
    
    [[UIColor blackColor] setFill];
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
    [[UIColor grayColor] setFill];
    [cmtBgrd fill];

    [[UIColor blackColor] setFill];
    CGSize commMaxSize = CGSizeMake(contentRect.size.width, currHeight);
    CGSize commSize = [@"TODO" sizeWithFont:_commentFont 
                             constrainedToSize:commMaxSize 
                                 lineBreakMode:UILineBreakModeTailTruncation];
    CGPoint commPt = CGPointMake(contentRect.origin.x + (contentRect.size.width - commSize.width), 
                                 currY + (currHeight - commSize.height));
    [@"TODO" drawAtPoint:commPt withFont:_commentFont];
    

}





@end
