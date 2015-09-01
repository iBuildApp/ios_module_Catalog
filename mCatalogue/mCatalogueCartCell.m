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


#import "mCatalogueCartCell.h"
#import "UIButton+Extensions.h"

#define kDeleteTitleLeftMargin   0.f
#define kDeleteTitleRightMargin  0.f
#define kDeleteTitleTopMargin    0.f
#define kDeleteTitleBottomMargin 0.f

#define kDeleteTitleScaleRatio 0.8f

@implementation mCatalogueCartDeleteButton

-(void)sizeToFit
{
  CGRect frm = self.frame;
  
  // calculate text size
  // the size of title is bottom limited with delete button height
  CGSize maxSize = CGSizeMake( 9999, 9999 );
  
  CGSize expectedSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                         constrainedToSize:maxSize
                                             lineBreakMode:self.titleLabel.lineBreakMode];
  expectedSize.width  += kDeleteTitleLeftMargin + kDeleteTitleRightMargin;
  CGSize imgSize = [self.imageView.image size];
  CGFloat titleHeight = floorf(self.titleLabel.font.lineHeight * ( 1 + kDeleteTitleScaleRatio) +
                               kDeleteTitleTopMargin  + kDeleteTitleBottomMargin);
  CGSize size = CGSizeMake( expectedSize.width,
                           MAX( imgSize.height, titleHeight ) );
  // the image must be square formed, adding height of image to the total width
  size.width += size.height;
  frm.size = size;
  self.frame = frm;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect frm = self.bounds;
  CGRect imgViewFrame = CGRectZero;
  if ( self.imageView.image )
  {
    imgViewFrame = CGRectMake( 0.f, 0.f, frm.size.height, frm.size.height );
    self.imageView.frame  = imgViewFrame;
  }
  
  self.titleLabel.frame = CGRectMake( CGRectGetMaxX( imgViewFrame ) + kDeleteTitleLeftMargin,
                                     kDeleteTitleTopMargin,
                                     CGRectGetMaxX( frm ) - CGRectGetMaxX( imgViewFrame ) - kDeleteTitleLeftMargin - kDeleteTitleRightMargin,
                                     CGRectGetHeight(frm) - (kDeleteTitleTopMargin + kDeleteTitleBottomMargin) );
}

@end


@implementation mCatalogueCartCell
@synthesize    priceLabel = _priceLabel,
              amountField = _amountField,
             deleteButton = _deleteButton,
                     item = _item,
             containImage = _containImage,
                 delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      _priceLabel   = nil;
      _amountField  = nil;
      _deleteButton = nil;
      _item         = nil;
      _delegate     = nil;
    }
    return self;
}

-(void)dealloc
{
  [_priceLabel removeFromSuperview];
  [_priceLabel release];
  
  [_amountField removeFromSuperview];
  [_amountField release];
  
  [_deleteButton removeFromSuperview];
  [_deleteButton release];
  
  self.item      = nil;
  [super dealloc];
}

-(UILabel *)priceLabel
{
  if ( !_priceLabel )
  {
    _priceLabel = [[NRLabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_priceLabel];
  }
  return _priceLabel;
}

-(UITextField *)amountField
{
  if ( !_amountField )
  {
    _amountField = [[mCatalogueTextField alloc] initWithFrame:CGRectZero];
    _amountField.delegate = self;
    [self.contentView addSubview:_amountField];
  }
  return _amountField;
}

-(UIButton *)deleteButton
{
  if ( !_deleteButton )
  {
    _deleteButton = [[mCatalogueCartDeleteButton alloc] initWithFrame:CGRectZero];
    [_deleteButton addTarget:self
                      action:@selector(didDeleteItem:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // extend button tap area
    [_deleteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    [self.contentView addSubview:_deleteButton];
  }
  return _deleteButton;
}

#pragma mark
#pragma mark UIButtonHandlers
-(void)didDeleteItem:(UIButton *)sender
{
  if ( [self.delegate respondsToSelector:@selector(didDeleteCell:)] )
    [self.delegate performSelector:@selector(didDeleteCell:)
                        withObject:self];
  
  [self.amountField resignFirstResponder];
}

#pragma mark
#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  [textField selectAll:self];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if ( self.amountField == textField )
  {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( [self.amountField validateInputString:newString] )
    {
      
      NSString *value = [newString length] ? newString : textField.placeholder;
      [self changeCartItemCount:value];
      
    }else{
      
      return NO;
      
    }
  }
  return YES;
}

-(void)changeCartItemCount:(NSString *)value
{
  [self.item setCountWithString:value
                       validate:YES];
  
  if([self.delegate respondsToSelector:@selector(didChangeItemsForCell:)])
  {
    [self.delegate performSelector:@selector(didChangeItemsForCell:)
                        withObject:self];
  }
}


@end
