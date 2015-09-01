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

#import "mCatalogueSearchBarView.h"
#import "NSString+size.h"
#import "UIColor+HSL.h"

@interface mCatalogueSearchBarView()
{
    CGRect searchTextFieldCollapsedFrame;
    CGRect searchTextFieldExpandedFrame;
    BOOL _cartButtonHidden;
}
    @property (nonatomic, assign, readwrite) mCatalogueSearchBarViewAppearance appearance;
    @property (nonatomic, retain) UILabel *cancelSearchLabel;
    @property (nonatomic, retain) UIView *searchIconView;
    @property (nonatomic, retain) UIView *hamburgerView;
    @property (nonatomic, retain) UIView *backLabelView;
    @property (nonatomic, retain) UILabel *titleLabel;
    @property (nonatomic, retain) UILabel *foundApplicationsCountLabel;
    @property (nonatomic, retain) UIView *separator;
@end

@implementation mCatalogueSearchBarView{
  /**
   * Width for hamburger imageview
   * or back item depending on appearance
   */
  CGFloat leftItemWith;
}

@synthesize searchInProgress = searchInProgress;

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
      self.appearance = mCatalogueSearchBarViewDefaultAppearance;
      NSLog(@"mCatalogueSearchBarView: WARNING initWithFrame: constructor invoked, assuming mCatalogueSearchBarViewDefaultAppearance");
      [self setupSelf];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame apperance:(mCatalogueSearchBarViewAppearance) appearance
{
  self = [super initWithFrame:frame];
  
  if(self){
    self.appearance = appearance;
    [self setupSelf];
  }
  return self;
}

- (id)initWithApperance:(mCatalogueSearchBarViewAppearance) appearance
{
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenWidth = screenRect.size.width;
  CGRect searchBarRect = (CGRect){0.0f, 0.0f, screenWidth, kToolbarHeight};
  
  self = [super initWithFrame:searchBarRect];
  
  if(self){
    self.appearance = appearance;
    [self setupSelf];
  }
  return self;
}

- (void)setupSelf
{
  searchInProgress = NO;
  _titleLabel = nil;
  _backButtonLabel = nil;
  _searchTextField = nil;
  _cancelSearchLabel = nil;
  _searchIconView = nil;
  _hamburgerView = nil;
  _foundApplicationsCountLabel = nil;
  _cartButton = nil;
  
  switch(self.appearance){
    case mCatalogueSearchBarViewHamburgerAppearance:
      [self placeHamburgerImageView];
      break;
    default:
      NSLog(@"mCatalogueSearchBarView: WARNING unrecognized appearance, assumed mCatalogueSearchBarViewDefaultAppearance");
    case mCatalogueSearchBarViewPureNavigationAppearance:
    case mCatalogueSearchBarViewDefaultAppearance:
      [self placeNavigationBackView];
      break;
  }
  
  [self placeSearchIconImageView];
  
  [self placeCartButton]; //hidden by default
  
  [self placeTitleLabel];
  
  if(self.appearance == mCatalogueSearchBarViewPureNavigationAppearance){
    
    self.searchIconView.hidden = YES;
    
  } else {
    
    [self placeCancelSearchLabel];
    self.cancelSearchLabel.hidden = YES;
    
    [self placeSearchTextField];
    self.searchTextField.hidden = YES;
    
  }

  self.backgroundColor = [UIColor blackColor];
}

- (void) centerView:(UIView *)view
{
  CGFloat centerY = self.frame.size.height / 2;
  
  CGPoint viewCenter = view.center;
  viewCenter.y = centerY;
  view.center = viewCenter;
}

- (void) placeNavigationBackView
{
  self.backLabelView = [[[UIView alloc] initWithFrame:(CGRect){0.0f, 0.0f, 82.0f, self.frame.size.height}] autorelease];
  UIImage *backImg = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_back")];
  UIImageView *backImgView = [[[UIImageView alloc] initWithImage:backImg] autorelease];
  backImgView.frame = (CGRect){7.0f, 0.0f, 13.0f, 20.0f};
  [self centerView:backImgView];
  [self.backLabelView addSubview:backImgView];
  
  self.backButtonLabel = [[[UILabel alloc] init] autorelease];
  _backButtonLabel.frame = (CGRect){23.0f, 0.0f, 64.0f, self.frame.size.height};
  _backButtonLabel.textAlignment = NSTextAlignmentLeft;
  _backButtonLabel.text = NSBundleLocalizedString(@"mCatalogue_Back", @"Back");
  _backButtonLabel.textColor = [UIColor blackColor];
  _backButtonLabel.font = [UIFont systemFontOfSize: 16];
  _backButtonLabel.backgroundColor = [UIColor clearColor];
  [self centerView:_backButtonLabel];
  [self.backLabelView addSubview:_backButtonLabel];
  
  UITapGestureRecognizer *backTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonPressed)] autorelease];
  [self.backLabelView addGestureRecognizer:backTapRecognizer];
  [self addSubview:self.backLabelView];
}

- (void) placeHamburgerImageView
{
    self.hamburgerView = [[[UIView alloc] initWithFrame:(CGRect){0.0f, 0.0f, kToolbarHeight, kToolbarHeight}] autorelease];
    self.hamburgerView.userInteractionEnabled = YES;
    [self addSubview:self.hamburgerView];
  
    UITapGestureRecognizer *hamburgerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonPressed)];
    [self.hamburgerView addGestureRecognizer:hamburgerTapRecognizer];
    
    UIImage *hamburger = [UIImage imageNamed:@"hamburger"]; //not used
    UIImageView *hamburgerImageView = [[[UIImageView alloc] initWithImage:hamburger] autorelease];
    CGRect hamburgerFrame = hamburgerImageView.frame;
    hamburgerFrame.origin.x = kHamburgerPadding;
    hamburgerFrame.origin.y = 0.0f;
    
    hamburgerImageView.frame = hamburgerFrame;
    hamburgerImageView.center =  (CGPoint){hamburgerImageView.center.x, self.hamburgerView.center.y};
    
    [self.hamburgerView addSubview:hamburgerImageView];
}

- (void) placeSearchIconImageView
{
    CGFloat tapAreaOriginX = self.frame.size.width - kToolbarHeight;
    
    self.searchIconView = [[[UIView alloc] initWithFrame:(CGRect){tapAreaOriginX, 0.0f, kToolbarHeight, kToolbarHeight}] autorelease];
    self.searchIconView.backgroundColor = [UIColor clearColor];
    self.searchIconView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *searchIconTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchIconTapped)];
    [self.searchIconView addGestureRecognizer:searchIconTapRecognizer];
    [self addSubview:self.searchIconView];
    
    CGFloat searchIconOriginX = kToolbarHeight - kSearchIconWidth - kSearchIconPaddingRight;
    
    UIImage *searchIcon = [UIImage imageNamed:resourceFromBundle(@"mCatalogue_search")];
    UIImageView *searchIconImageView = [[[UIImageView alloc] initWithImage:searchIcon] autorelease];
    
    CGRect searchIconFrame = (CGRect){searchIconOriginX, 0.0f, kSearchIconWidth, kSearchIconWidth};
    searchIconImageView.frame = searchIconFrame;
    searchIconImageView.center = (CGPoint){(int)searchIconImageView.center.x, (int)(kToolbarHeight/2)};
    
    [self.searchIconView addSubview:searchIconImageView];
}

- (void) placeCartButton
{
  _cartButtonHidden = YES;
  CGRect cartButtonFrame = CGRectMake(self.frame.size.width - kToolbarHeight, 0.0f, kToolbarHeight, kToolbarHeight);
  
  self.cartButton = [[[mCatalogueCartButton alloc] initWithFrame:cartButtonFrame] autorelease];
  
  [self.cartButton addTarget:self
                        action:@selector(cartButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
  
  self.cartButton.count = 10;
  
  [self addSubview:self.cartButton];
}

- (void) placeTitleLabel
{
  self.titleLabel = [[[UILabel alloc] init] autorelease];
  
  switch(self.appearance){
    case mCatalogueSearchBarViewHamburgerAppearance:
      //not used
      break;
    case mCatalogueSearchBarViewDefaultAppearance:
      break;
    case mCatalogueSearchBarViewPureNavigationAppearance:
    default:
      break;
  }
  
  _titleLabel.font = [UIFont systemFontOfSize:kMainPageTitleFontSize];
  _titleLabel.textColor = kMainPageTitleFontColor;
  _titleLabel.backgroundColor = [UIColor clearColor];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  CGFloat titleLabelWidth =  CGRectGetMinX(self.searchIconView.frame) - 12.0f - CGRectGetMaxX(self.backLabelView.frame);
  
  CGRect titleLabelFrame = (CGRect){CGRectGetMaxX(self.backLabelView.frame) + 6.0f, 0.0f, titleLabelWidth, kToolbarHeight / 2};
  _titleLabel.frame = titleLabelFrame;
  
  self.titleLabel.center = (CGPoint){self.bounds.size.width / 2, kToolbarHeight / 2};
  
  [self addSubview:_titleLabel];
}

- (void) placeCancelSearchLabel
{
    self.cancelSearchLabel = [[[UILabel alloc] init] autorelease];
    self.cancelSearchLabel.font = [UIFont systemFontOfSize:kCancelLabelFontSize];
    
    NSString *labelText = NSBundleLocalizedString(@"mCatalogue_CancelSearch", @"Cancel");
    
    CGSize cancelSearchLabelSize = [labelText sizeForFont:self.cancelSearchLabel.font limitSize:self.frame.size];
    CGFloat cancelSearchLabelOriginX = self.bounds.size.width - kCancelLabelHorizontalPadding - cancelSearchLabelSize.width;
    CGFloat cancelSearchLabelOriginY = 0.0f;
    
    CGRect cancelLabelFrame = (CGRect){cancelSearchLabelOriginX, cancelSearchLabelOriginY, cancelSearchLabelSize.width, kToolbarHeight};
    
    self.cancelSearchLabel.frame = cancelLabelFrame;
    self.cancelSearchLabel.backgroundColor = [UIColor clearColor];
    self.cancelSearchLabel.text = labelText;
    self.cancelSearchLabel.textColor = kCancelLabelFontColor;
    self.cancelSearchLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *cancelSearchTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)] autorelease];
    
    [self.cancelSearchLabel addGestureRecognizer:cancelSearchTapRecognizer];
    
    [self addSubview:self.cancelSearchLabel];
}

- (void) placeSearchTextField
{
    self.searchTextField = [[[UITextField alloc] init] autorelease];
  
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
  
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
        self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    
    searchTextFieldCollapsedFrame = (CGRect){self.cancelSearchLabel.frame.origin.x - kCancelLabelHorizontalPadding,
        (self.frame.size.height - kSearchTextFieldHeight) / 2,
        0.0f,
        kSearchTextFieldHeight};

    CGFloat searchTextFieldWidth = self.frame.size.width - (kCancelLabelHorizontalPadding + 2 * kCancelLabelHorizontalPadding + self.cancelSearchLabel.frame.size.width);
    
    searchTextFieldExpandedFrame = (CGRect){kCancelLabelHorizontalPadding, searchTextFieldCollapsedFrame.origin.y, searchTextFieldWidth, kSearchTextFieldHeight};
    
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.delegate = self.mCatalogueSearchViewTextFieldDelegate;
    self.searchTextField.borderStyle = UITextBorderStyleNone;
    self.searchTextField.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.searchTextField.layer.cornerRadius = kSearchBarTextFieldCornerRadius;
    self.searchTextField.font = [UIFont systemFontOfSize:kSearchBarTextViewFontSize];
    self.searchTextField.textAlignment = NSTextAlignmentLeft;
    
    UIView *spacerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, kSearchTextFieldHeight)] autorelease];
    [self.searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.searchTextField setLeftView:spacerView];
  
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
  
    [self setupSearchPlaceholder];
  
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.searchTextField.frame = searchTextFieldCollapsedFrame;
    self.searchTextField.delegate = self;
  
    [self addSubview:self.searchTextField];
  
    [self placeFoundApplicationsCountRightView];
}

-(void)setupSearchPlaceholder{
  NSString *placeholderText = NSBundleLocalizedString(@"mCatalogue_SearchPlaceholder", @"Search");
  
  if ([self.searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
    UIColor *color = [UIColor blackColor];
    self.searchTextField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color}] autorelease];
  } else {
    self.searchTextField.placeholder = placeholderText;
  }
}

- (void) placeSeparator
{
  CGRect separatorFrame = (CGRect){0.0f, kToolbarHeight, self.frame.size.width, kToolbarSeparatorHeight};
  
  self.separator = [[[UIView alloc] initWithFrame:separatorFrame] autorelease];
  
  if([self.backgroundColor isLight]){
    self.separator.backgroundColor = kSeparatorColorDark;
  } else {
    self.separator.backgroundColor = kSeparatorColorLight;
  }
  
  self.separatorColor = self.separator.backgroundColor;
  
  [self addSubview:self.separator];
}

- (void) leftButtonPressed
{
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewLeftButtonPressed)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewLeftButtonPressed];
  }
}

- (void) cartButtonPressed
{
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewCartButtonPressed)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewCartButtonPressed];
  }
}

- (void) searchIconTapped
{
  searchInProgress = !searchInProgress;
  
  [self setupSearchPlaceholder];
  
  switch(self.appearance){
    case mCatalogueSearchBarViewHamburgerAppearance:
      self.hamburgerView.hidden = YES;
      break;
    case mCatalogueSearchBarViewDefaultAppearance:
      self.backLabelView.hidden = YES;
      break;
    case mCatalogueSearchBarViewPureNavigationAppearance:
    default:
      break;
  }
  
  self.titleLabel.hidden = YES;
  self.searchIconView.hidden = YES;
  self.cartButton.hidden = YES;
  
  self.cancelSearchLabel.alpha = 0.0f;
  self.cancelSearchLabel.hidden = NO;
  self.searchTextField.hidden = NO;
  
  [self.searchTextField becomeFirstResponder];
  
  [UIView animateWithDuration:0.2f animations:^{
    self.cancelSearchLabel.alpha = 1.0f;
  }];
  
  [UIView animateWithDuration:0.3f animations:^{
    self.searchTextField.frame = searchTextFieldExpandedFrame;
  } completion:^(BOOL completed){
    if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewDidShowSearchField)]){
      [self.mCatalogueSearchViewDelegate mCatalogueSearchViewDidShowSearchField];
    }
  }];
}

- (void) cancelSearch
{
  searchInProgress = !searchInProgress;
  
  self.searchTextField.text = @"";
  self.searchTextField.placeholder = @"";
  
  self.titleLabel.alpha = 0.0f;
  self.titleLabel.hidden = NO;
  
  self.searchIconView.alpha = 0.0f;
  self.searchIconView.hidden = NO;
  if (!_cartButtonHidden)
  {
    self.cartButton.hidden = NO;
    self.cartButton.alpha = 0.0f;
  }
  
  switch(self.appearance){
    case mCatalogueSearchBarViewHamburgerAppearance:
      self.hamburgerView.alpha = 0.0f;
      self.hamburgerView.hidden = NO;
      break;
    case mCatalogueSearchBarViewDefaultAppearance:
      self.backLabelView.alpha = 0.0f;
      self.backLabelView.hidden = NO;
      break;
    case mCatalogueSearchBarViewPureNavigationAppearance:
    default:
      break;
  }
  
  if([self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewDidCancelSearch)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewDidCancelSearch];
  }
  
  [UIView animateWithDuration:0.3f animations:^{
    self.searchTextField.frame = searchTextFieldCollapsedFrame;
    [self.searchTextField resignFirstResponder];
  } completion:^(BOOL finished){
    self.cancelSearchLabel.hidden = YES;
    self.searchTextField.hidden = YES;
    
    [UIView animateWithDuration:0.1f animations:^{
      self.titleLabel.alpha = 1.0f;
      self.searchIconView.alpha = 1.0f;
      if (!_cartButtonHidden)
        self.cartButton.alpha = 1.0f;
        
      switch(self.appearance){
        case mCatalogueSearchBarViewHamburgerAppearance:
          self.hamburgerView.alpha = 1.0f;
          break;
        case mCatalogueSearchBarViewDefaultAppearance:
          self.backLabelView.alpha = 1.0f;
          break;
        case mCatalogueSearchBarViewPureNavigationAppearance:
        default:
          break;
      }
    }];
    
  }];
}


- (void) setmCatalogueSearchViewTextFieldDelegate:(id<NSObject,UITextFieldDelegate>)mCatalogueSearchViewTextFieldDelegate {
    if(_mCatalogueSearchViewTextFieldDelegate != mCatalogueSearchViewTextFieldDelegate){
        _mCatalogueSearchViewTextFieldDelegate = mCatalogueSearchViewTextFieldDelegate;
        self.searchTextField.delegate = _mCatalogueSearchViewTextFieldDelegate;
    }
}

- (void) setTitle:(NSString *)title
{
  if(_title != title){
    [_title release];
    _title = [title retain];
    self.titleLabel.text = _title;
    self.titleLabel.center = (CGPoint){self.bounds.size.width / 2, kToolbarHeight / 2};
    
    if(self.titleLabel.frame.origin.x <= (self.backLabelView.frame.origin.x + self.backLabelView.frame.size.width + 6.0f)){
      CGRect shiftedTitleFrame = self.titleLabel.frame;
      shiftedTitleFrame.origin.x += 6.0f;
      self.titleLabel.frame = shiftedTitleFrame;
    }
  }
}

- (void) setSeparatorColor:(UIColor *)separatorColor
{
  if(_separatorColor != separatorColor){
    [separatorColor retain];
    [_separatorColor release];
    
    _separatorColor = separatorColor;
    
    _separator.backgroundColor = _separatorColor;
  }
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
  [super setBackgroundColor:backgroundColor];
  
  if([self.backgroundColor isLight]){
    [self setSeparatorColor:kSeparatorColorDark];
  } else {
    [self setSeparatorColor:kSeparatorColorLight];
  }
}



-(void)placeFoundApplicationsCountRightView
{
  self.foundApplicationsCountLabel = [[[UILabel alloc] init] autorelease];
  self.foundApplicationsCountLabel.textColor = kAppCountTextColor;
  self.foundApplicationsCountLabel.backgroundColor = [UIColor clearColor];
  self.foundApplicationsCountLabel.font = [UIFont systemFontOfSize:12.0f];
  
  [self.searchTextField setRightViewMode:UITextFieldViewModeUnlessEditing];
  [self.searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
  [self.searchTextField setRightView:self.foundApplicationsCountLabel];
}

- (void)clearSearchResultsCount
{
  self.foundApplicationsCountLabel.text = @"";
}

- (void)refreshSearchResultsCount:(NSUInteger)newValue
{
  NSString *countAsString = [NSString stringWithFormat:@"%ld", (long)newValue];
  
  self.foundApplicationsCountLabel.text = countAsString;
  self.foundApplicationsCountLabel.textColor = kAppCountTextColor;
  [self.foundApplicationsCountLabel sizeToFit];
  
  CGRect newFrame = self.foundApplicationsCountLabel.frame;
  newFrame.size.width += 5.0f;
  self.foundApplicationsCountLabel.frame = newFrame;
}

-(void) setCartButtonHidden:(BOOL)value
{
  if (_cartButtonHidden != value)
  {
    CGPoint c = self.searchIconView.center;
    CGRect r = self.titleLabel.frame;
    if (value)
    {
      c.x += kToolbarHeight;
      r.size = CGSizeMake(r.size.width + kToolbarHeight, r.size.height);
    }
    else
    {
      c.x -= kToolbarHeight;
      r.size = CGSizeMake(r.size.width - kToolbarHeight, r.size.height);
    }
    
    self.searchIconView.center = c;
    self.titleLabel.frame = r;
    
    self.cartButton.hidden = value;
    _cartButtonHidden = value;
  }
}

-(BOOL) cartButtonHidden
{
  return self.cartButton ? self.cartButton.hidden : YES;
}


#pragma mark - UITextField delegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
  return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  
  if(self.mCatalogueSearchViewDelegate && [self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewSearchInitiated:)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewSearchInitiated:textField.text];
  }
  
  return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
  textField.text = @"";
  
  if(self.mCatalogueSearchViewDelegate && [self.mCatalogueSearchViewDelegate respondsToSelector:@selector(mCatalogueSearchViewSearchInitiated:)]){
    [self.mCatalogueSearchViewDelegate mCatalogueSearchViewSearchInitiated:textField.text];
  }
  
  return NO;
}

- (void) dealloc
{
    self.titleLabel = nil;
    self.backButtonLabel = nil;
    self.searchTextField = nil;
    self.cancelSearchLabel = nil;
    self.searchIconView = nil;
    self.hamburgerView = nil;
    self.foundApplicationsCountLabel = nil;
    self.separatorColor = nil;
    self.cartButton = nil;
  
    [super dealloc];
}

@end
