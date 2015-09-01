/****************************************************************************
 *                                                                           *
 *  Copyright (C) 2014-2015 iBuildApp, Inc. ( http://ibuildapp.com )         *
 *                                                                           *
 *  This file is part of iBuildApp.                                          *
 *                                                                           *
 *  This Source Code Form is subject to the terms of the iBuildApp License.  *
 *  You can obtain one at http://ibuildapp.com/license/                      *
 *                                                                           *
 ****************************************************************************/

#import "mExternalLinkWebViewController.h"

#import "iphnavbardata.h"

#define kCustomNavBarHeight 66.0f
#define kCatalogueNavBarColor [[UIColor blackColor] colorWithAlphaComponent:0.2f]

@interface mExternalLinkWebViewController(){
  BOOL movingOut;
}

@property (nonatomic, strong) UIColor *navBarInitialBarTintColor;
@property (nonatomic, strong) UIColor *navBarInitialTintColor;
@property (nonatomic, strong) NSDictionary *initialTitleAttributes;

@end

@implementation mExternalLinkWebViewController

-(void)dealloc
{
  self.navBarColor = nil;
  
  self.navBarInitialBarTintColor = nil;
  self.navBarInitialTintColor = nil;
  self.initialTitleAttributes = nil;
  
  [super dealloc];
}

- (void) showTBButton
{
  [super showTBButton];
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    [[tbButton imageView] setTintColor:[UIColor blackColor]];
    
    UIImage *tintedImage = [[tbButton imageForState:tbButton.state] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [tbButton setImage:tintedImage forState:UIControlStateNormal];
    tbButton.tintColor = [UIColor blackColor];
  }
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
  movingOut = NO;
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(customizeNavBarAppearanceCompleted:)
                                               name:TIPhoneNavBarDataCustomizeNavBarAppearanceCompleted
                                             object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [super hideTBButton];
  [self setNavBarTitle:[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"] animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if(self.isMovingFromParentViewController){
    movingOut = YES;
  }
}

-(void)setURL:(NSString *)url
{
  [super setURL:url];
  self.navigationItem.title = url;
}

-(void)setNavBarTitle:(NSString *)title animated:(BOOL)animated
{
  if(title.length){
    if(animated){
      [UIView transitionWithView:self.navigationController.navigationBar
                        duration:0.2f
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        self.navigationItem.title = title;
                      }
                      completion:nil];
    } else {
      self.navigationItem.title = title;
    }
  } else {
    self.navigationItem.title = self.URL;
  }
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  [super webViewDidFinishLoad:webView];
  [self setNavBarTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"] animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)customizeNavBarAppearanceCompleted:(NSNotification *)notification
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
  
  if(!movingOut){
    [self prettifyNavBar];
  } else {
    [self restoreStatusBarAppearance];
  }
}

-(void)restoreStatusBarAppearance
{
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    
    if(self.navBarInitialBarTintColor){
      [self.navigationController.navigationBar setBarTintColor:self.navBarInitialBarTintColor];
    }
    
    if(self.navBarInitialTintColor){
      [self.navigationController.navigationBar setTintColor:self.navBarInitialTintColor];
    }
    if(self.initialTitleAttributes){
      [self.navigationController.navigationBar setTitleTextAttributes:self.initialTitleAttributes];
    }
  }
}

-(void)prettifyNavBar
{
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    
    if(self.navBarColor){
      if(!self.navBarInitialBarTintColor){
        self.navBarInitialBarTintColor = self.navigationController.navigationBar.barTintColor;
        [self.navigationController.navigationBar setBarTintColor:self.navBarColor];
      }
      
      if(!self.navBarInitialTintColor){
        self.navBarInitialTintColor = self.navigationController.navigationBar.tintColor;
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
      }
    }
    
    if(!self.initialTitleAttributes){
      self.initialTitleAttributes = [self.navigationController.navigationBar.titleTextAttributes copy];
      [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                                        NSFontAttributeName : [UIFont systemFontOfSize:18.0f]}];
    }
  }
}

@end
