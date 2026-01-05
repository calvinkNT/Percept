#import "AICommands.h"

#define PREFS_PATH @"/var/mobile/Library/Preferences/uk.calvink19.percept.plist"
// friggin ssl yo
#define PROXY_URL @"https://calvink19.co/services/smartsiri-proxy.php"

@implementation AIAssistantExtension

-(id)initWithSystem:(id<SESystem>)system {
    if ((self = [super init])) {
        [system registerCommand:[AICommands class]];
    }
    return self;
}

-(NSString*)author { return @"calvink19"; }
-(NSString*)name { return @"Percept"; }
-(NSString*)description { return @"Makes Siri just a little bit smarter."; }

@end

@implementation AICommands

-(id)init {
    if ((self = [super init])) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)dealloc {
    [_queue release];
    [super dealloc];
}

-(void)processRequest:(NSString*)text {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    NSString *apiKey = [prefs objectForKey:@"apiKey"];
    
    if ([apiKey length] == 0) {
        [_ctx sendAddViewsUtteranceView:@"Please set your API key in the Percept settings panel first." speakableText:@""];
        [_ctx sendRequestCompleted];
        _ctx = nil;
        return;
    }
        
    NSURL *url = [NSURL URLWithString:PROXY_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:apiKey forHTTPHeaderField:@"X-API-Key"];
    [request setTimeoutInterval:15.0];
    
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"user", @"role",
                             text, @"content",
                             nil];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"gpt-3.5-turbo", @"model",
                          [NSArray arrayWithObject:message], @"messages",
                          [NSNumber numberWithInt:500], @"max_tokens",
                          nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    
    if (error) {
        [_ctx sendAddViewsUtteranceView:@"Failed to create request."];
        [_ctx sendRequestCompleted];
        _ctx = nil;
        return;
    }
    
    [request setHTTPBody:jsonData];
    
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!_ctx) return;
    
    if (error || !data) {
        [_ctx sendAddViewsUtteranceView:@"Network error." speakableText:@""];
        [_ctx sendRequestCompleted];
        _ctx = nil;
        return;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error || !json) {
        [_ctx sendAddViewsUtteranceView:@"Failed to parse response." speakableText:@""];
        [_ctx sendRequestCompleted];
        _ctx = nil;
        return;
    }
    
    NSArray *choices = [json objectForKey:@"choices"];
    if ([choices count] > 0) {
        NSDictionary *choice = [choices objectAtIndex:0];
        NSDictionary *messageDict = [choice objectForKey:@"message"];
        NSString *content = [messageDict objectForKey:@"content"];
        
        if (content && [content length] > 0) {
            content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [_ctx sendAddViewsUtteranceView:content];
            [_ctx sendRequestCompleted];
            _ctx = nil;
            return;
        }
    }
    
    [_ctx sendAddViewsUtteranceView:@"Invalid network response, please try again later." speakableText:@""];
    [_ctx sendRequestCompleted];
    _ctx = nil;
}

-(BOOL)handleSpeech:(NSString*)text tokens:(NSArray*)tokens tokenSet:(NSSet*)tokenset context:(id<SEContext>)ctx {
    
    if (_ctx) return NO;
    
    _ctx = ctx;
    
    NSString *reflection = @"...";
    [ctx sendAddViewsUtteranceView:reflection speakableText:@"" dialogPhase:@"Reflection" scrollToTop:NO temporary:NO];
        
    [self performSelectorInBackground:@selector(processRequest:) withObject:text];
    
    return YES;
}
@end