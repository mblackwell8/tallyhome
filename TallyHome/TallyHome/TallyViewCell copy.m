//
//  TallyViewCell.m
//  TallyHome
//
//  Created by Mark Blackwell on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyViewCell.h"

#define kDefaultTallyViewCellDateLabelHeight 0.23
#define kDefaultTallyViewCellValueLabelHeight 0.54
#define kDefaultTallyViewCellCommentLabelHeight 0.23

@implementation TallyViewCell

@synthesize dateLabel = _dateLabel, valueLabel = _valueLabel, commentLabel = _commentLabel, data = _data;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:10.0];
        
        UILabel *dtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height * kDefaultTallyViewCellDateLabelHeight)];
        self.dateLabel = dtLbl;
        [dtLbl release];
        _dateLabel.text = @"Date";
        _dateLabel.textAlignment = UITextAlignmentLeft;
        _dateLabel.font = [font fontWithSize:10.0];
        _dateLabel.textColor = [UIColor blackColor];
        
        CGFloat currY = _dateLabel.frame.size.height;
        UILabel *vLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, currY, frame.size.width, frame.size.height * kDefaultTallyViewCellValueLabelHeight)];
        self.valueLabel = vLbl;
        [vLbl release];
        _valueLabel.text = @"Value";
        _valueLabel.textAlignment = UITextAlignmentCenter;
        _valueLabel.font = [font fontWithSize:20.0];
        _valueLabel.textColor = [UIColor blackColor];
        
        currY += _valueLabel.frame.size.height;
        UILabel *cLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, currY, frame.size.width, frame.size.height * kDefaultTallyViewCellCommentLabelHeight)];
        self.commentLabel = cLbl;
        [cLbl release];
        _commentLabel.text = @"Comment";
        _commentLabel.textAlignment = UITextAlignmentRight;
        _commentLabel.font = [font fontWithSize:10.0];
        _commentLabel.textColor = [UIColor blackColor];
        
        [self addSubview:_dateLabel];
        [self addSubview:_valueLabel];
        [self addSubview:_commentLabel];
        
        for (UILabel *l in self.subviews) {
            l.numberOfLines = 1;
            //l.minimumFontSize = 4;
            //l.adjustsFontSizeToFitWidth = YES;
            //l.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        
        self.userInteractionEnabled = NO;
        //self.autoresizesSubviews = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews {
    _dateLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 
                                  self.frame.size.height * kDefaultTallyViewCellDateLabelHeight);
    CGFloat currY = _dateLabel.frame.size.height;
    _valueLabel.frame = CGRectMake(0.0, currY, self.frame.size.width, 
                                   self.frame.size.height * kDefaultTallyViewCellValueLabelHeight);
    currY += _valueLabel.frame.size.height;
    _commentLabel.frame = CGRectMake(0.0, currY, self.frame.size.width, 
                                     self.frame.size.height * kDefaultTallyViewCellCommentLabelHeight);
    
    [super layoutSubviews];
}

- (void)dealloc {
    self.dateLabel = nil;
    self.valueLabel = nil;
    self.commentLabel = nil;
    self.data = nil;
    [super dealloc];
}

@end
