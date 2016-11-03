//
//  AOMemoryTextField.h
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 AO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Enums.h"

FOUNDATION_EXPORT double AOMemoryTextFieldVersionNumber;

FOUNDATION_EXPORT const unsigned char AOMemoryTextFieldVersionString[];


@protocol AOMemoryTextFieldDataManagerDelegate <NSObject>

- (void)getMemorizedWordsWithKey:(NSString *)key withCompletion:(void(^)(NSArray<NSString *> *)) completionBlock;
- (void)saveNewWord:(NSString *)word;

@end


@interface AOMemoryTextField : UITextField

@property (nonatomic, weak) id<AOMemoryTextFieldDataManagerDelegate> dataManagerDelegate;

/**
    Set the key used to read from the NSUserDefaults. If you don´t set this key, will be used the default key. TextFields with same key will share the same autocomplete words.
 */
- (void)setNameKey:(NSString *)key;

/**
    Set the number of words that you want to save. When you reach this number, will start to remove the oldest words.
 */
- (void)setMemoryCapacity:(NSUInteger)capacity;

/**
    Set how you want that the results will be selected:
        - kAOFilterResultsLongestFirst : first suggests the longest words
 
        - kAOFilterResultsShortestFirst : first suggests the shortest words
 
        - kAOFilterResultsLastInFirstOut : first suggests the lasts words saved
 
        - kAOFilterResultsFirstInFirstOut : first suggests the firsts words saved
 */
- (void)setFilterResultsPolicy:(kAOFilterResults)resultsPolicy;

/**
    Set a predicate that will be used to evaluate if the textField's text is correct to be saved.(optional)
 */
- (void)setEvaluationPredicate:(NSPredicate *)predicate;

/**
    Invoke this method when you want to save the current textField's word.
 */
- (void)saveNewEntry;

/**
    Invoke this method when you want to delete all the words.
 */
- (void)clearMemory;


- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
