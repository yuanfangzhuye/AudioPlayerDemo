#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSFileManager (THAdditions)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;

@end
