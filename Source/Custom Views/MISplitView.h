//
//  MISplitView.h
//  MacIrssi
//
//  Created by Matt Wright on 27/12/2008.
//  Copyright 2008 Matt Wright Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MISplitView : NSSplitView {

}

- (void)saveLayoutUsingName:(NSString*)name;
- (void)restoreLayoutUsingName:(NSString*)name;

@end
