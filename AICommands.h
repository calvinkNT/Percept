#import "SiriObjects.h"
#import <Foundation/Foundation.h>

@interface AIAssistantExtension : NSObject<SEExtension>
-(id)initWithSystem:(id<SESystem>)system;
-(NSString*)author;
-(NSString*)name;
-(NSString*)description;
@end

@interface AICommands : NSObject<SECommand> {
    id<SEContext> _ctx;
    NSOperationQueue *_queue;
}
-(BOOL)handleSpeech:(NSString*)text tokens:(NSArray*)tokens tokenSet:(NSSet*)tokenset context:(id<SEContext>)ctx;
@end