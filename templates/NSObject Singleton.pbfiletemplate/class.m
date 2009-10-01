«OPTIONALHEADERIMPORTLINE»

static «FILEBASENAMEASIDENTIFIER» *sharedInstance;

@implementation «FILEBASENAMEASIDENTIFIER»

#pragma mark -
#pragma mark Singleton methods

+ («FILEBASENAMEASIDENTIFIER»*)sharedInstance {
    @synchronized(self) {
		    if (sharedInstance == nil) {
			      sharedInstance = [[«FILEBASENAMEASIDENTIFIER» alloc] init];
	      }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end