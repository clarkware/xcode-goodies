«OPTIONALHEADERIMPORTLINE»

@implementation «FILEBASENAMEASIDENTIFIER»

@synthesize image;
@synthesize currentColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.currentColor = [UIColor blueColor];
        self.image = [UIImage imageNamed:@"example.png"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGRect aRect = CGRectMake(0, 0, self.image.size.width,
                                    self.image.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw something
}

- (void)dealloc {
    [image release];
    [currentColor release];
    [super dealloc];
}

@end
