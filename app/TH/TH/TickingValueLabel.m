//
//  TickingValueLabel.m
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TickingValueLabel.h"
#import "DebugMacros.h"

#import <QuartzCore/QuartzCore.h>

@interface TickingValueLabel ()

@property (nonatomic, retain) NSString *valueStr;
@property (nonatomic, retain) NSNumberFormatter *valueFormatter;
@property (nonatomic, retain) NSMutableArray *centLabels, *tenCentLabels;

@end

@implementation TickingValueLabel

@synthesize value = _value, valueStr = _valueStr, valueFormatter = _valueFormatter, font = _font, textColor = _textColor, tenCentLabels = _tenCentLabels, centLabels = _centLabels;

- (void)doInit {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init]; 
    [nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
    [nf setMaximumFractionDigits:0];
    self.valueFormatter = nf;
    [nf release];
    
    _font = [[UIFont systemFontOfSize:40.0] retain];
    _textColor = [[UIColor whiteColor] retain];
}

- (id)init {
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [_font release];
    [_textColor release];
    [_valueStr release];
    [_valueFormatter release];
    [_centLabels release];
    [_tenCentLabels release];
}

- (void)scrollCentsHigher {
    //if the cent label is 9 then we need to scroll the tenCentLabel too
    int centIntOne = [[[_centLabels objectAtIndex:1] text] intValue];
    BOOL scrollTenCents = (centIntOne == 9);
    
    [UIView beginAnimations:nil context:NULL];
    
    //make label 0 visible
    UILabel *centLblZero = [_centLabels objectAtIndex:0];
    UILabel *tenCentLblZero = [_tenCentLabels objectAtIndex:0];
    centLblZero.hidden = NO;
    if (scrollTenCents)
        tenCentLblZero.hidden = NO;
    
    //scroll labels 0 and 1 down by their height
    CGFloat scrollY = centLblZero.frame.size.height;
    centLblZero.center = CGPointMake(centLblZero.center.x, centLblZero.center.y + scrollY);
    if (scrollTenCents)
        tenCentLblZero.center = CGPointMake(tenCentLblZero.center.x, tenCentLblZero.center.y + scrollY);
    
    UILabel *centLblOne = [_centLabels objectAtIndex:1];
    UILabel *tenCentLblOne = [_tenCentLabels objectAtIndex:1];
    
    centLblOne.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    
 
    [UIView commitAnimations];
    
    centLblOne.center = CGPointMake(centLblOne.center.x, centLblOne.center.y + scrollY);
    if (scrollTenCents)
        tenCentLblOne.center = CGPointMake(tenCentLblOne.center.x, tenCentLblOne.center.y + scrollY);
    
    
    
    
    //make label 1 hidden
//    centLblOne.hidden = YES;
    if (scrollTenCents)
        tenCentLblOne.hidden = YES;
    
    //move label 2 up 2 x scroll, back to where label zero was
    UILabel *centLblTwo = [_centLabels objectAtIndex:2];
    UILabel *tenCentLblTwo = [_tenCentLabels objectAtIndex:2];
    centLblTwo.center = CGPointMake(centLblTwo.center.x, centLblOne.center.y - scrollY * 2.0);
    if (scrollTenCents)
        tenCentLblTwo.center = CGPointMake(tenCentLblTwo.center.x, tenCentLblTwo.center.y - scrollY * 2.0);
    
    //... and set its text to be one more than centLblZero, mod 10
    int centIntZero = [centLblZero.text intValue];
    int newCentIntTwo = (centIntZero + 1) % 10;
    centLblTwo.text = [NSString stringWithFormat:@"%d", newCentIntTwo];
    if (scrollTenCents) {
        int tenCentIntZero = [tenCentLblZero.text intValue];
        int newTenCentIntTwo = (tenCentIntZero + 1) % 10;
        tenCentLblTwo.text = [NSString stringWithFormat:@"%d", newTenCentIntTwo];
    }
    
    //then re-order the array
    [centLblTwo retain];
    [_centLabels removeObjectAtIndex:2];
    [_centLabels insertObject:centLblTwo atIndex:0];
    [centLblTwo release];
    if (scrollTenCents) {
        [tenCentLblTwo retain];
        [_tenCentLabels removeObjectAtIndex:2];
        [_tenCentLabels insertObject:tenCentLblTwo atIndex:0];
        [tenCentLblTwo release];

    }
}

- (void)scrollCentsLower {

}

- (void)setValue:(double)value {
    double oldVal = _value;
    _value = value;
    
    DLog(@"updating old val %0.2f to new val %0.2f", oldVal, _value);
    
    //round down the value otherwise the dollar ticks over at 0.50
    NSString *newVal = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:floor(value)]];
    if (![newVal isEqualToString:_valueStr]) {
        self.valueStr = newVal;
        [self setNeedsLayout];
    }
    else {
        //scroll the decimal places
        double oldCents, newCents;
        
        //use floor rather than round otherwise we can end up with 100 cents
        oldCents = floor((oldVal - floor(oldVal)) * 100.0);
        newCents = floor((value - floor(value)) * 100.0);
        
        //if we've scrolled across a dollar then we should've used the code above
        NSAssert(ABS(oldCents - newCents) < 100.0, @"");
        
        while (oldCents != newCents) {
            if (oldCents < newCents) {
                [self scrollCentsHigher];
                oldCents += 1.0;
            }
            else {
                [self scrollCentsLower];
                oldCents -= 1.0;
            }
        }
    }
}

- (void)layoutSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //create a UILabel for the non-decimal part, 
    
    NSString *fullLabel = [_valueStr stringByAppendingString:@".00"];
    CGSize frameSz = self.frame.size;
    CGSize fullLblSz = [fullLabel sizeWithFont:_font 
                             constrainedToSize:frameSz
                                 lineBreakMode:UILineBreakModeMiddleTruncation];
    
    CGPoint dollarlblPt = CGPointMake((frameSz.width - fullLblSz.width) / 2.0, 
                                      (frameSz.height - fullLblSz.height) / 2.0);
    //NSString *dollarLblStr = [_valueStr stringByAppendingString:@"."];
    CGSize dollarLblSz = [_valueStr sizeWithFont:_font
                                  constrainedToSize:fullLblSz
                                      lineBreakMode:UILineBreakModeMiddleTruncation];
    CGRect dollarLblFr = CGRectMake(dollarlblPt.x, dollarlblPt.y, dollarLblSz.width, dollarLblSz.height);
    UILabel *dollarLbl = [[UILabel alloc] initWithFrame:dollarLblFr];
    dollarLbl.text = _valueStr;
    dollarLbl.textColor = _textColor;
    dollarLbl.backgroundColor = [UIColor clearColor];
    dollarLbl.font = _font;
    dollarLbl.alpha = 1.0;
    [self addSubview:dollarLbl];
    [dollarLbl release];
    
    //have separate labels for the the two decimal places,
    //plus UILabel above and below each digit
    //these are monospaced to allow for scrolling...
    UIFont *_centFont = [_font fontWithSize:_font.pointSize * 0.6];
    CGSize digitSz = [@"0" sizeWithFont:_centFont];
    
    double cents = round((_value - floor(_value)) * 100.0);
    //DLog(@"cents is %2.2f", cents);
    NSString *centsStr = [NSString stringWithFormat:@"%02.f", cents];
    //DLog(@"or %@", centsStr);
    NSString *centsMinusOneStep = [NSString stringWithFormat:@"%02.f", 
                                   (int)(cents - 9) % 10 == 0 ? cents + 1 : cents + 11];
    NSString *centsPlusOneStep = [NSString stringWithFormat:@"%02.f",
                                   (int)cents % 10 == 0 ? cents - 1 : cents - 11];
    NSArray *centsStrs = [NSArray arrayWithObjects:centsMinusOneStep, centsStr, centsPlusOneStep, nil];
    
    CGPoint digitPt = CGPointMake(dollarlblPt.x + dollarLblSz.width + 7.0, dollarlblPt.y + 3.0);
    int posn, i;
    for (posn = 0; posn < 2; posn++) {
        NSMutableArray *lbls = [[NSMutableArray alloc] init];
        for (i = 0; i < 3; i++) {
            CGRect r = CGRectMake(digitPt.x + posn * digitSz.width, 
                                  digitPt.y + (i-1) * digitSz.height, 
                                  digitSz.width, digitSz.height);
            UILabel *digitLbl = [[UILabel alloc] initWithFrame:r];
            digitLbl.font = _centFont;
            digitLbl.text = [[centsStrs objectAtIndex:i] substringWithRange:NSMakeRange(posn, 1)];
            digitLbl.textColor = _textColor;
            digitLbl.backgroundColor = [UIColor clearColor];
            digitLbl.alpha = 1.0;
            digitLbl.hidden = (i != 1);
            [self addSubview:digitLbl];
            [lbls addObject:digitLbl];
            [digitLbl release];
            //DLog(@"Digit label '%@' at %@", digitLbl.text, NSStringFromCGRect(r));
        }
        if (posn == 0)
            self.tenCentLabels = lbls;
        else
            self.centLabels = lbls;
        [lbls release];
    }
    
}

//- (void)drawRect:(CGRect)rect {
//    //draw everything to left of dec place
//    
//    //draw everything to right of dec place, in smaller text, aligned top
//    
//}

@end
