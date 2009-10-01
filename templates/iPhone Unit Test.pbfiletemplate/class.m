#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
 
@interface «FILEBASENAMEASIDENTIFIER» : SenTestCase {
}
@end

@implementation «FILEBASENAMEASIDENTIFIER»

#pragma mark -
#pragma mark Setup/teardown

- (void)setUp {
    NSLog(@"%@ setUp", self.name);
}

- (void)tearDown {
    NSLog(@"%@ tearDown", self.name);
}

#pragma mark -
#pragma mark Tests

-(void)testSomethingAlready {
    STAssertTrue(NO, nil);
}

@end
