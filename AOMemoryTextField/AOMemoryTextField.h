//
//  AOMemoryTextField.h
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 AO. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double AOMemoryTextFieldVersionNumber;

FOUNDATION_EXPORT const unsigned char AOMemoryTextFieldVersionString[];


@protocol AOMemoryTextFieldDataManagerDelegate <NSObject>

- (void)getMemorizedWordsWithKey:(NSString *)key withCompletion:(void(^)(NSArray<NSString *> *)) completionBlock;
- (void)saveNewWord:(NSString *)word;

@end


@interface AOMemoryTextField : UITextField

@property (nonatomic, weak) id<AOMemoryTextFieldDataManagerDelegate> dataManagerDelegate;

- (void)setNameKey:(NSString *)key;
- (void)setMemoryCapacity:(NSUInteger)capacity;
- (void)clearMemory;
- (void)saveNewEntry;
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
