#! /bin/sh

headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogue.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueBaseVC.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCart+priceWidth.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCart.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartAlertView.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartButton.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartCell.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartItem.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartItemCell.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartOrderView.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCartVC.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCategory.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueCategoryView.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueConfirmInfo.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueConfirmationManager.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueEntry.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueEntryView.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueGridCell.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueItem.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueItemVC.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueItemView.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueOrder.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueOrderConfirmVC.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueParameters.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueRowCell.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueTextField.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueThankYouPageVC.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueUserProfile.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mCatalogueUserProfileCell.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/mExternalLinkWebViewController.h

headerdoc2html -j -o mCatalogue/Documentation mCatalogue/DB/mCatalogueDBManager.h
headerdoc2html -j -o mCatalogue/Documentation mCatalogue/searchNavBar/mCatalogueSearchBarView.h

gatherheaderdoc mCatalogue/Documentation


sed -i.bak 's/<html><body>//g' mCatalogue/Documentation/masterTOC.html
sed -i.bak 's|<\/body><\/html>||g' mCatalogue/Documentation/masterTOC.html
sed -i.bak 's|<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">||g' mCatalogue/Documentation/masterTOC.html


