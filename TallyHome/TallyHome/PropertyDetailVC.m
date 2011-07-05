//
//  TallyViewController.m
//  TallyHome
//
//  Created by Mark Blackwell on 25/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropertyDetailVC.h"


@implementation PropertyDetailVC

@synthesize propertyName = _propertyName, estCurrentValue = _estCurrentValue, chartActivityIndicator = _chartActivityIndicator, estPropValActivityIndicator = _estPropValActivityIndicator, chartView = _chartView, chart = _chart, pricePath = _pricePath, location = _location, propertyNameStr = _propertyNameStr;

- (id)init {
    if ((self = [self initWithNibName:@"PropertyDetailVC" bundle:nil])) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.location = kUnknownLocation;
        self.propertyNameStr = self.location;
    }
    return self;
}

#pragma mark NSCoding

#define kVerNoCoding    @"VerNo"
#define kLocation       @"Location"
//#define kPurchDate      @"PurchDate"
//#define kPurchPrice     @"PurchPrice"
#define kPropertyName   @"PropName"
#define kPricePath      @"PricePath"


- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    
    [encoder encodeObject:_location forKey:kLocation];
//    [encoder encodeObject:_purchDate forKey:kPurchDate];
//    [encoder encodeDouble:purchasePrice forKey:kPurchPrice];
    [encoder encodeObject:_propertyName.text forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        if (!(self.location = [decoder decodeObjectForKey:kLocation])) {
            self.location = kUnknownLocation;
        }
//        if (!(self.purchaseDate = [decoder decodeObjectForKey:kPurchDate])) {
//            self.purchaseDate = nil;
//        }
//        if ((self.purchasePrice = [decoder decodeDoubleForKey:kPurchPrice]) == 0.0) {
//            self.purchasePrice = kUnknownPurchPrice;
//        }
        if (!(self.propertyNameStr = [decoder decodeObjectForKey:kPropertyName])) {
            self.propertyNameStr = self.location;
        }
        if (!(self.pricePath = [decoder decodeObjectForKey:kPricePath])) {
            self.pricePath = nil;
        }
    }
    
    return self;
}

#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    THTimeSeries *ts = [_pricePath makePricePath];
    THDateVal *latestVal = [ts calcValueAt:[NSDate date]];
    
    return [NSString stringWithFormat:@"%.2f", latestVal.val];
}
- (NSString *)rowTitle {
    return _propertyNameStr;
}


- (void)dealloc {
    [_propertyName release];
    [_estCurrentValue release];
    [_estPropValActivityIndicator release];
    [_chartActivityIndicator release];
    [_chart release];
    [_displayData release];
    [_pricePath release];
    [_customiseAlert release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
}

- (void)viewDidAppear:(BOOL)animated {
    //start the activity indicators
    [_chartActivityIndicator startAnimating];
    [_estPropValActivityIndicator startAnimating];
    
    [self _initPricePath];
    [self _initChart];
    
    [_chartActivityIndicator stopAnimating];
    [_estPropValActivityIndicator stopAnimating];
}

- (void)_initPricePath {
    THURLCreator *urlCreator = [[THURLCreator alloc] init];
    self.pricePath = [[THHomePricePath alloc] initWithURL:[urlCreator makeURL]];
    _displayData = [_pricePath makePricePath];
    [urlCreator release];
    [_displayData retain];

}

- (void)_initChart {
    CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
    _chart = (CPXYGraph *)[theme newGraph];	
    _chartView.hostedGraph = _chart;
    
    _chart.paddingLeft = 10.0;
    _chart.paddingTop = 10.0;
    _chart.paddingRight = 10.0;
    _chart.paddingBottom = 10.0;
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)_chart.defaultPlotSpace;
    NSTimeInterval xLow = [[[_displayData objectAtIndex:0] date] timeIntervalSince1970];
    
    //display 10 years of data
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(xLow) 
                                                   length:CPDecimalFromFloat(TH_OneDayInSecs * 365.0f * 10.0f)];
    THDateVal *maxVal = [_displayData maxValue];    
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromDouble((maxVal ? maxVal.val : 5.0))];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)_chart.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromFloat(TH_OneDayInSecs * 365.0f);
    x.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.0f);
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *timeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    
    //TODO: once have data, set the reference date (this appears to be the first date?)
    //timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
    
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.orthogonalCoordinateDecimal = CPDecimalFromFloat(0.0f);
    
    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";
    
	CPMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [_chart addPlot:dataSourceLinePlot];

}

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return _displayData.count;
}
-(NSNumber *)numberForPlot:(CPPlot *)plot 
                     field:(NSUInteger)fieldEnum 
               recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPScatterPlotFieldX: {
            id i = [_displayData objectAtIndex:index];
            return [NSNumber numberWithDouble:[[i date] timeIntervalSince1970]];
        }
        case CPScatterPlotFieldY: {
            id i = [_displayData objectAtIndex:index];
            return [NSNumber numberWithDouble:[i val]];
        }
    }
    return nil;
}

- (void)viewDidUnload {
    self.estPropValActivityIndicator = nil;
    self.chart = nil;
    [_customiseAlert release];
    _customiseAlert = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
