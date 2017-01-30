//
//  SearchTextField.h
//  Coding Challenge Demo
//
//  Created by Iftekhar on 30/01/17.
//  Copyright © 2017 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchTextField;

@protocol SearchTextFieldDelegate <UITextFieldDelegate>

@optional
- (void)textFieldDidStartTyping:(nonnull SearchTextField *)textField;
- (void)textFieldDidStopTyping:(nonnull SearchTextField *)textField;

@end

@interface SearchTextField : UITextField

@property NSTimeInterval stopDelay;
@property(readonly) BOOL isTyping;

@property(nullable, nonatomic,weak) id<SearchTextFieldDelegate> delegate;

@end
