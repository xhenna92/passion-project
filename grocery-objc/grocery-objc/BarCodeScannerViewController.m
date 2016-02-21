//
//  BarCodeScannerViewController.m
//  grocery-objc
//
//  Created by Henna Ahmed on 2/20/16.
//  Copyright © 2016 Shena Yoshida. All rights reserved.
//

#import "BarCodeScannerViewController.h"

@interface BarCodeScannerViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *resultsView;

@end

@implementation BarCodeScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.barcodeTypes = TFBarcodeTypeEAN8 | TFBarcodeTypeEAN13 | TFBarcodeTypeUPCA | TFBarcodeTypeUPCE | TFBarcodeTypeQRCODE;
    self.resultsView.alpha = 0.0f;
    self.overlayView.alpha = 0.0f;
    
    NSLog(@"%d", self.hasCamera);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - TFBarcodeScannerViewController

- (void)barcodePreviewWillShowWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.overlayView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

- (void)barcodePreviewWillHideWithDuration:(CGFloat)duration
{
    
}


- (void)barcodeWasScanned:(NSSet *)barcodes
{
    [self stop];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    TFBarcode* barcode = [barcodes anyObject];
    self.resultsView.hidden = NO;
    NSLog([self stringFromBarcodeType:barcode.type]);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.resultsView.alpha = 1.0f;
    }];
}

#pragma mark - Private

- (NSString *)stringFromBarcodeType:(TFBarcodeType)barcodeType
{
    static NSDictionary *typeMap;
    
    if (!typeMap) {
        typeMap = @{
                    @(TFBarcodeTypeEAN8):         @"EAN8",
                    @(TFBarcodeTypeEAN13):        @"EAN13",
                    @(TFBarcodeTypeUPCA):         @"UPCA",
                    @(TFBarcodeTypeUPCE):         @"UPCE",
                    @(TFBarcodeTypeQRCODE):       @"QRCODE",
                    @(TFBarcodeTypeCODE128):      @"CODE128",
                    @(TFBarcodeTypeCODE39):       @"CODE39",
                    @(TFBarcodeTypeCODE39Mod43):  @"CODE39Mod43",
                    @(TFBarcodeTypeCODE93):       @"CODE93",
                    @(TFBarcodeTypePDF417):       @"PDF417",
                    @(TFBarcodeTypeAztec):        @"Aztec"
                    };
    }
    
    return typeMap[@(barcodeType)];
}


@end
