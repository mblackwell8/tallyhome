//
//  TickingValueLabel.m
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TickingValueLabel.h"
#import "DebugMacros.h"


@interface TickingValueLabel ()

//@property (nonatomic, retain) NSString *valueStr;
@property (nonatomic, retain) NSNumberFormatter *valueFormatter;
@property (nonatomic, retain) FlipLabel *centLabel, *tenCentLabel;

- (void)layoutLabel;

@end

@implementation TickingValueLabel

@synthesize value = _value, valueFormatter = _valueFormatter, dollarLabel = _dollarLabel, font = _font, textColor = _textColor, tenCentLabel = _tenCentLabel, centLabel = _centLabel;

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
//    [_valueStr release];
    [_valueFormatter release];
    [_centLabel release];
    [_tenCentLabel release];
}

- (void)setValue:(double)value {
    double oldVal = _value;
    _value = value;
    
    //DLog(@"updating old val %0.2f to new val %0.2f", oldVal, _value);
        
    if (_dollarLabel == nil) {
        [self layoutLabel];
        return;
    }
    
    NSString *newVal = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:floor(_value)]];
    if (![newVal isEqualToString:_dollarLabel.text]) {
        _dollarLabel.text = newVal;
    }
    
    //scroll the decimal places
    double oldCents, newCents;
    
    //use floor rather than round otherwise we can end up with 100 cents
    oldCents = floor((oldVal - floor(oldVal)) * 100.0);
    newCents = floor((value - floor(value)) * 100.0);
    
//    NSAssert(oldCents == 10.0 * _tenCentLabel.digit + _centLabel.digit, @"cents out of sync");
    
    NSAssert(oldCents >= 0.0 && oldCents < 100.0, @"error");
    NSAssert(newCents >= 0.0 && newCents < 100.0, @"error");
    
    if (newCents == 0.0 && oldCents == 99.0) {
        [_tenCentLabel flipForwardTo:0 withAnimation:YES];
        [_centLabel flipForwardTo:0 withAnimation:YES];
    }
    else if (newCents == 99.0 && oldCents == 0.0) {
        [_tenCentLabel flipBackwardTo:9 withAnimation:YES];
        [_centLabel flipBackwardTo:9 withAnimation:YES];
    }
    else if (floor(newCents / 10.0) > floor(oldCents / 10.0)) {
        [_tenCentLabel flipForwardTo:newCents / 10.0 withAnimation:YES];
        [_centLabel flipForwardTo:0 withAnimation:YES];            
    }
    else if (floor(newCents / 10.0) < floor(oldCents / 10.0)) {
        [_tenCentLabel flipBackwardTo:newCents / 10.0 withAnimation:YES];
        [_centLabel flipBackwardTo:9 withAnimation:YES];
    }
    else if ((int)newCents % 10 > (int)oldCents % 10) {
        [_centLabel flipForwardTo:(int)newCents % 10 withAnimation:YES];
    }
    else if ((int)newCents % 10 < (int)oldCents % 10) {
        [_centLabel flipBackwardTo:(int)newCents % 10 withAnimation:YES];
    }
}


//originally this was layoutSubviews... but doesn't need to be and the transform
//animations in DoubleSidedLabel call layoutSubviews on parent view... invalidating everythin
- (void)layoutLabel {
    //DLog(@"doing...");
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //create a UILabel for the non-decimal part, 
    
    
    //round down the value otherwise the dollar ticks over at 0.50
    NSString *newVal = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:floor(_value)]];
    
    NSString *fullLabel = [newVal stringByAppendingString:@"00"];
    CGSize frameSz = self.frame.size;
    CGSize fullLblSz = [fullLabel sizeWithFont:_font 
                             constrainedToSize:frameSz
                                 lineBreakMode:UILineBreakModeMiddleTruncation];
    
    CGPoint dollarlblPt = CGPointMake((frameSz.width - fullLblSz.width) / 2.0, 
                                      (frameSz.height - fullLblSz.height) / 2.0);
    //NSString *dollarLblStr = [_valueStr stringByAppendingString:@"."];
    CGSize dollarLblSz = [newVal sizeWithFont:_font
                                  constrainedToSize:fullLblSz
                                      lineBreakMode:UILineBreakModeMiddleTruncation];
    CGRect dollarLblFr = CGRectMake(dollarlblPt.x, dollarlblPt.y, dollarLblSz.width, dollarLblSz.height);
    UILabel *dollarLbl = [[UILabel alloc] initWithFrame:dollarLblFr];
    dollarLbl.text = newVal;
    dollarLbl.textColor = _textColor;
    dollarLbl.backgroundColor = [UIColor clearColor];
    dollarLbl.font = _font;
    dollarLbl.alpha = 1.0;
    dollarLbl.adjustsFontSizeToFitWidth = YES;
    [self addSubview:dollarLbl];
    self.dollarLabel = dollarLbl;
    [dollarLbl release];
    
    //have separate labels for the the two decimal places,
    UIFont *_centFont = [_font fontWithSize:_font.pointSize * 0.6];
    CGSize digitSz = [@"0" sizeWithFont:_centFont];
    
    double cents = floor((_value - floor(_value)) * 100.0);
    //DLog(@"cents is %2.2f", cents);
    //NSString *centsStr = [NSString stringWithFormat:@"%02.f", cents];
    //DLog(@"or %@", centsStr);
    CGPoint digitPt = CGPointMake(dollarlblPt.x + dollarLblSz.width + 7.0, dollarlblPt.y + 3.0);
    int posn;
    for (posn = 1; posn >= 0; posn--) {
        CGRect r = CGRectMake(digitPt.x + posn * digitSz.width, 
                              digitPt.y, digitSz.width, digitSz.height);
        
        FlipLabel *digitLbl = [[FlipLabel alloc] initWithFrame:r];
        digitLbl.font = _centFont;
        digitLbl.textColor = _textColor;
        
        digitLbl.backgroundColor = [UIColor blackColor];
        
        digitLbl.digit = floor(cents / pow(10.0, posn));
        cents -= digitLbl.digit * pow(10.0, posn);
        
        [self addSubview:digitLbl];
        if (posn == 0)
            self.tenCentLabel = digitLbl;
        else
            self.centLabel = digitLbl;
        [digitLbl release];
        //DLog(@"Digit label '%@' at %@", digitLbl.text, NSStringFromCGRect(r));
    }
}

//- (void)drawRect:(CGRect)rect {
//    //draw everything to left of dec place
//    
//    //draw everything to right of dec place, in smaller text, aligned top
//    
//}

@end
