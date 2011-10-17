//
//  TickingValueLabel.m
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TickingValueLabel.h"
#import "DebugMacros.h"
#import "DoubleSidedLabel.h"

@interface TickingValueLabel ()

@property (nonatomic, retain) NSString *valueStr;
@property (nonatomic, retain) NSNumberFormatter *valueFormatter;
@property (nonatomic, retain) NSMutableArray *centLabels, *tenCentLabels;

- (void)layoutLabel;

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

//- (void)scrollCentsHigher {
//    //if the cent label is 9 then we need to scroll the tenCentLabel too
//    int centIntOne = [[[_centLabels objectAtIndex:1] text] intValue];
//    BOOL scrollTenCents = (centIntOne == 9);
//    
//    [UIView beginAnimations:nil context:NULL];
//    
//    //make label 0 visible
//    UILabel *centLblZero = [_centLabels objectAtIndex:0];
//    UILabel *tenCentLblZero = [_tenCentLabels objectAtIndex:0];
//    centLblZero.hidden = NO;
//    if (scrollTenCents)
//        tenCentLblZero.hidden = NO;
//    
//    //scroll labels 0 and 1 down by their height
//    CGFloat scrollY = centLblZero.frame.size.height;
//    centLblZero.center = CGPointMake(centLblZero.center.x, centLblZero.center.y + scrollY);
//    if (scrollTenCents)
//        tenCentLblZero.center = CGPointMake(tenCentLblZero.center.x, tenCentLblZero.center.y + scrollY);
//    
//    UILabel *centLblOne = [_centLabels objectAtIndex:1];
//    UILabel *tenCentLblOne = [_tenCentLabels objectAtIndex:1];
//    centLblOne.center = CGPointMake(centLblOne.center.x, centLblOne.center.y + scrollY);
//    if (scrollTenCents)
//        tenCentLblOne.center = CGPointMake(tenCentLblOne.center.x, tenCentLblOne.center.y + scrollY);
//    
//    
//    [UIView commitAnimations];
//    
//    //make label 1 hidden
//    centLblOne.hidden = YES;
//    if (scrollTenCents)
//        tenCentLblOne.hidden = YES;
//    
//    //move label 2 up 2 x scroll, back to where label zero was
//    UILabel *centLblTwo = [_centLabels objectAtIndex:2];
//    UILabel *tenCentLblTwo = [_tenCentLabels objectAtIndex:2];
//    centLblTwo.center = CGPointMake(centLblTwo.center.x, centLblOne.center.y - scrollY * 2.0);
//    if (scrollTenCents)
//        tenCentLblTwo.center = CGPointMake(tenCentLblTwo.center.x, tenCentLblTwo.center.y - scrollY * 2.0);
//    
//    //... and set its text to be one more than centLblZero, mod 10
//    int centIntZero = [centLblZero.text intValue];
//    int newCentIntTwo = (centIntZero + 1) % 10;
//    centLblTwo.text = [NSString stringWithFormat:@"%d", newCentIntTwo];
//    if (scrollTenCents) {
//        int tenCentIntZero = [tenCentLblZero.text intValue];
//        int newTenCentIntTwo = (tenCentIntZero + 1) % 10;
//        tenCentLblTwo.text = [NSString stringWithFormat:@"%d", newTenCentIntTwo];
//    }
//    
//    //then re-order the array
//    [centLblTwo retain];
//    [_centLabels removeObjectAtIndex:2];
//    [_centLabels insertObject:centLblTwo atIndex:0];
//    [centLblTwo release];
//    if (scrollTenCents) {
//        [tenCentLblTwo retain];
//        [_tenCentLabels removeObjectAtIndex:2];
//        [_tenCentLabels insertObject:tenCentLblTwo atIndex:0];
//        [tenCentLblTwo release];
//
//    }
//}
//
//- (void)scrollCentsLower {
//
//}

- (void)setValue:(double)value {
    double oldVal = _value;
    _value = value;
    
    //DLog(@"updating old val %0.2f to new val %0.2f", oldVal, _value);
    
    //round down the value otherwise the dollar ticks over at 0.50
    NSString *newVal = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:floor(value)]];
    if (![newVal isEqualToString:_valueStr]) {
        self.valueStr = newVal;
        [self layoutLabel];
    }
    else {
        //scroll the decimal places
        double oldCents, newCents;
        
        //use floor rather than round otherwise we can end up with 100 cents
        oldCents = floor((oldVal - floor(oldVal)) * 100.0);
        newCents = floor((value - floor(value)) * 100.0);
        
        NSAssert(oldCents >= 0.0 && oldCents < 100.0, @"error");
        NSAssert(newCents >= 0.0 && newCents < 100.0, @"error");
        
        DoubleSidedLabel *tenCentLbl = [_centLabels objectAtIndex:0];
        DoubleSidedLabel *centLbl = [_centLabels objectAtIndex:1];
        if (floor(oldCents / 10.0) != floor(newCents / 10.0)) {
            tenCentLbl.invisibleLabel.text = [NSString stringWithFormat:@"%d", floor(newCents / 10.0)];
            [tenCentLbl flipWithAnimation:YES];
        }
        
        if ((int)oldCents % 10 != (int)newCents % 10) {
            centLbl.invisibleLabel.text = [NSString stringWithFormat:@"%d", (int)newCents % 10];
            [centLbl flipWithAnimation:YES];
        }
    }
}


//originally this was layoutSubviews... but doesn't need to be and the transform
//animations in DoubleSidedLabel call layoutSubviews on parent view... invalidating everythin
- (void)layoutLabel {
    //DLog(@"doing...");
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
    
    double cents = floor((_value - floor(_value)) * 100.0);
    //DLog(@"cents is %2.2f", cents);
    NSString *centsStr = [NSString stringWithFormat:@"%02.f", cents];
    //DLog(@"or %@", centsStr);
    CGPoint digitPt = CGPointMake(dollarlblPt.x + dollarLblSz.width + 7.0, dollarlblPt.y + 3.0);
    NSMutableArray *lbls = [[NSMutableArray alloc] init];
    int posn;
    for (posn = 0; posn < 2; posn++) {
        CGRect r = CGRectMake(digitPt.x + posn * digitSz.width, 
                              digitPt.y, digitSz.width, digitSz.height);
        
        DoubleSidedLabel *digitLbl = [[DoubleSidedLabel alloc] initWithFrame:r];
        digitLbl.font = _centFont;
        digitLbl.textColor = [UIColor whiteColor];
        
        digitLbl.visibleLabel.text = [centsStr substringWithRange:NSMakeRange(posn, 1)];
        
        [self addSubview:digitLbl];
        [lbls addObject:digitLbl];
        [digitLbl release];
        //DLog(@"Digit label '%@' at %@", digitLbl.text, NSStringFromCGRect(r));
    }
    
    self.centLabels = lbls;
    [lbls release];    
}

//- (void)drawRect:(CGRect)rect {
//    //draw everything to left of dec place
//    
//    //draw everything to right of dec place, in smaller text, aligned top
//    
//}

@end
