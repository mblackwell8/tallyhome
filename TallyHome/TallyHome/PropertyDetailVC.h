//
//  TallyViewController.h
//  TallyHome
//
//  Created by Mark Blackwell on 25/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "THHomePricePath.h"
#import "THURLCreator.h"
#import "TallyDetailVC.h"

#define kUnknownLocation @"Unknown"

@interface PropertyDetailVC: TallyDetailVC <CPPlotDataSource> {
    NSString *_location;
    NSString *_propertyNameStr;
    
    // provided in THHomePricePath
//    NSDate *_purchDate;
//    double purchasePrice;
    
    IBOutlet UILabel *_propertyName;
    IBOutlet UILabel *_estCurrentValue;
    IBOutlet UIActivityIndicatorView *_chartActivityIndicator;    
    IBOutlet UIActivityIndicatorView *_estPropValActivityIndicator;
    IBOutlet CPGraphHostingView *_chartView;
    IBOutlet UIImageView *_customiseAlert;
    CPXYGraph *_chart;
    
    THHomePricePath *_pricePath;
    THTimeSeries *_displayData;
}

@property (nonatomic, retain) NSString *location;
//@property (nonatomic, retain) NSDate *purchaseDate;
//@property double purchasePrice;

@property (nonatomic, retain) UILabel *propertyName;
@property (nonatomic, retain) NSString *propertyNameStr;
@property (nonatomic, retain) UILabel *estCurrentValue;
@property (nonatomic, retain) UIActivityIndicatorView *chartActivityIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *estPropValActivityIndicator;
@property (nonatomic, retain) CPGraphHostingView *chartView;
@property (nonatomic, retain) CPXYGraph *chart;
@property (nonatomic, retain) THHomePricePath *pricePath;

- (void)_initPricePath;
- (void)_initChart;

//@protocol CPPlotDataSource <NSObject>

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot; 

//@optional

// Implement one of the following
//-(NSArray *)numbersForPlot:(CPPlot *)plot 
//                     field:(NSUInteger)fieldEnum 
//          recordIndexRange:(NSRange)indexRange; 

-(NSNumber *)numberForPlot:(CPPlot *)plot 
                     field:(NSUInteger)fieldEnum 
               recordIndex:(NSUInteger)index; 
//
//-(NSRange)recordIndexRangeForPlot:(CPPlot *)plot 
//                        plotRange:(CPPlotRange *)plotRect;

//@end

@end
