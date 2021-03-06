//
//  SKTestRules.m
//  ScrapeKitWorkbench
//
//  Created by Craig Edwards on 3/01/13.
//  Copyright (c) 2013 BlackDog Foundry. All rights reserved.
//

#import "SKTestCase.h"
#import <ScrapeKit/ScrapeKit.h>

@interface SKTestRules : SKTestCase
@end

@implementation SKTestRules

-(void)testCreateVar {
	NSString *script =
	@"@main\n"
	@"  createvar NSMutableDictionary mydict\n"
	@"  createvar NSMutableArray myarray\n"
	@"  createvar XXHouse myhouse\n"
	@"  createvar XXDoesntExist xxx\n"
	;
	
	NSString *data = @"";
	SKEngine *engine = [self runScript:script usingData:data];
	GHAssertTrue([[engine variableFor:@"mydict"] isKindOfClass:[NSMutableDictionary class]], nil);
	GHAssertTrue([[engine variableFor:@"myarray"] isKindOfClass:[NSMutableArray class]], nil);
	GHAssertTrue([[engine variableFor:@"myhouse"] isKindOfClass:[XXHouse class]], nil);
	GHAssertNil([engine variableFor:@"xxx"], nil);
}

-(void)testAssignConst {
	NSString *script =
	@"@main\n"
	@"  assignconst xxx myvar1\n"
	@"  assignconst yyy myvar2\n"
	@"  assignconst yyy2 myvar2\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	GHAssertEqualStrings([engine variableFor:@"myvar1"], @"xxx", nil);
	GHAssertEqualStrings([engine variableFor:@"myvar2"], @"yyy2", nil);
	GHAssertNil([engine variableFor:@"myvar3"], nil);
}

-(void)testMutableArray {
	NSString *script =
	@"@main\n"
	@"  createvar NSMutableArray array\n"
	@"  assignconst one array\n"
	@"  assignconst two array\n"
	@"  assignconst three array\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	id array = [engine variableFor:@"array"];
	GHAssertTrue([array isKindOfClass:[NSMutableArray class]], nil);
	GHAssertEquals([array count], (NSUInteger)3, nil);
	GHAssertEqualStrings(array[0], @"one", nil);
	GHAssertEqualStrings(array[1], @"two", nil);
	GHAssertEqualStrings(array[2], @"three", nil);
}

-(void)testArray {
	NSString *script =
	@"@main\n"
	@"  createvar NSArray array\n"
	@"  assignconst one array\n"
	@"  assignconst two array\n"
	@"  assignconst three array\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	id value = [engine variableFor:@"array"];
	// note that NSArray is not supported (only NSMutableArray), therefore
	// the engine will just replace the existing variable with the new one
	GHAssertTrue([value isKindOfClass:[NSString class]], nil);
	GHAssertEqualStrings(value, @"three", nil);
}

-(void)testMutableDictionary {
	NSString *script =
	@"@main\n"
	@"  createvar NSMutableDictionary dict\n"
	@"  assignconst one dict a\n"
	@"  assignconst two dict b\n"
	@"  assignconst three dict c\n"
	@"  assignconst four dict\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	id dict = [engine variableFor:@"dict"];
	GHAssertTrue([dict isKindOfClass:[NSMutableDictionary class]], nil);
	GHAssertEquals([dict count], (NSUInteger)3, nil);
	GHAssertEqualStrings(dict[@"a"], @"one", nil);
	GHAssertEqualStrings(dict[@"b"], @"two", nil);
	GHAssertEqualStrings(dict[@"c"], @"three", nil);
}

-(void)testObject {
	NSString *script =
	@"@main\n"
	@"  createvar XXAddress addr\n"
	@"  assignconst Sunset addr street\n"
	@"  assignconst Hollywood addr suburb\n"
	@"  assignconst CA addr state\n"
	@"  assignconst 90210 addr postcode\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	XXAddress *addr = [engine variableFor:@"addr"];
	GHAssertEqualStrings([addr street], @"Sunset", nil);
	GHAssertEqualStrings([addr suburb], @"Hollywood", nil);
	GHAssertEqualStrings([addr state], @"CA", nil);
	GHAssertEqualStrings([addr postcode], @"90210", nil);
}

-(void)testObjectComplex {
	NSString *script =
	@"@main\n"
	@"  # Create the array to hold all the houses\n"
	@"  createvar NSMutableArray houses\n"
	@"	"
	@"  # Create a new house\n"
	@"  createvar XXHouse house\n"
	@"  assignconst 1 house bedrooms\n"
	@"  assignconst 2 house bathrooms\n"
	@"	"
	@"  # Create a new address\n"
	@"  createvar XXAddress addr\n"
	@"  assignconst Sunset addr street\n"
	@"  assignconst Hollywood addr suburb\n"
	@"  assignconst CA addr state\n"
	@"  assignconst 90210 addr postcode\n"
	@"  assignvar addr house address\n"
	@"	"
	@"  # Create a couple of photos\n"
	@"  createvar NSMutableArray photos\n"
	@"  assignvar photos house photos\n"
	@"  createvar XXPhoto photo\n"
	@"  assignconst t1 photo title\n"
	@"  assignconst u1 photo url\n"
	@"  assignvar photo house photos\n"
	@"  createvar XXPhoto photo\n"
	@"  assignconst t2 photo title\n"
	@"  assignconst u2 photo url\n"
	@"  assignvar photo house photos\n"
	@"	"
	@"  # And now add the house to the array\n"
	@"  assignvar house houses\n"
	@"	"
	@"  # Create a second house\n"
	@"  createvar XXHouse house\n"
	@"  assignconst 3 house bedrooms\n"
	@"  assignconst 4 house bathrooms\n"
	@"	"
	@"  # Create a new address\n"
	@"  createvar XXAddress addr\n"
	@"  assignconst Railway addr street\n"
	@"  assignconst Dallas addr suburb\n"
	@"  assignconst TX addr state\n"
	@"  assignconst 12345 addr postcode\n"
	@"  assignvar addr house address\n"
	@"	"
	@"  # Create a single photo\n"
	@"  createvar NSMutableArray photos\n"
	@"  assignvar photos house photos\n"
	@"  createvar XXPhoto p1\n"
	@"  assignconst t3 p1 title\n"
	@"  assignconst u3 p1 url\n"
	@"  assignvar p1 house photos\n"
	@"	"
	@"  # And now add the house to the array\n"
	@"  assignvar house houses\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSArray *houses = [engine variableFor:@"houses"];
	GHAssertEquals([houses count], (NSUInteger)2, nil);

	GHAssertEquals([houses[0] bedrooms], (NSInteger)1, nil);
	GHAssertEquals([houses[0] bathrooms], (NSInteger)2, nil);
	XXAddress *address = [(XXHouse *)houses[0] address];
	GHAssertEqualStrings([address street], @"Sunset", nil);
	GHAssertEqualStrings([address suburb], @"Hollywood", nil);
	GHAssertEqualStrings([address state], @"CA", nil);
	GHAssertEqualStrings([address postcode], @"90210", nil);
	NSArray *photos = [houses[0] photos];
	GHAssertEquals([photos count], (NSUInteger)2, nil);
	GHAssertEqualStrings([photos[0] title], @"t1", nil);
	GHAssertEqualStrings([photos[0] url], @"u1", nil);
	GHAssertEqualStrings([photos[1] title], @"t2", nil);
	GHAssertEqualStrings([photos[1] url], @"u2", nil);
	
	GHAssertEquals([houses[1] bedrooms], (NSInteger)3, nil);
	GHAssertEquals([houses[1] bathrooms], (NSInteger)4, nil);
	address = [(XXHouse *)houses[1] address];
	GHAssertEqualStrings([address street], @"Railway", nil);
	GHAssertEqualStrings([address suburb], @"Dallas", nil);
	GHAssertEqualStrings([address state], @"TX", nil);
	GHAssertEqualStrings([address postcode], @"12345", nil);
	photos = [houses[1] photos];
	GHAssertEquals([photos count], (NSUInteger)1, nil);
	GHAssertEqualStrings([photos[0] title], @"t3", nil);
	GHAssertEqualStrings([photos[0] url], @"u3", nil);
}

-(void)testIf1 {
	NSString *script =
	@"@main\n"
	@"  createvar Blah wontwork\n"
	@"  ifsuccess success\n"
  @"  assignconst OK text\n"
	@"  goto end\n"
	@":success\n"
  @"  assignconst WRONG text\n"
	@":end\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *text = [engine variableFor:@"text"];
	GHAssertEqualStrings(text, @"OK", nil);
}

-(void)testIf2 {
	NSString *script =
	@"@main\n"
	@"  createvar Blah wontwork\n"
	@"  iffailure failure\n"
  @"  assignconst WRONG text\n"
	@"  goto end\n"
	@":failure\n"
  @"  assignconst OK text\n"
	@":end\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *text = [engine variableFor:@"text"];
	GHAssertEqualStrings(text, @"OK", nil);
}

-(void)testIf3 {
	NSString *script =
	@"@main\n"
	@"  createvar NSString willwork\n"
	@"  ifsuccess success\n"
  @"  assignconst WRONG text\n"
	@"  goto end\n"
	@":success\n"
  @"  assignconst OK text\n"
	@":end\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *text = [engine variableFor:@"text"];
	GHAssertEqualStrings(text, @"OK", nil);
}

-(void)testIf4 {
	NSString *script =
	@"@main\n"
	@"  createvar NSString willwork\n"
	@"  iffailure failure\n"
  @"  assignconst OK text\n"
	@"  goto end\n"
	@":failure\n"
  @"  assignconst WRONG text\n"
	@":end\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *text = [engine variableFor:@"text"];
	GHAssertEqualStrings(text, @"OK", nil);
}

-(void)testFunction1 {
	NSString *script =
	@"@main\n"
	@"  invoke func\n"
	@"\n"
	@"@func\n"
	@"  assignconst one a\n"
	@"  assignconst two b\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *a = [engine variableFor:@"a"];
	NSString *b = [engine variableFor:@"b"];
	GHAssertEqualStrings(a, @"one", nil);
	GHAssertEqualStrings(b, @"two", nil);
}


-(void)testFunction2 {
	NSString *script =
	@"@main\n"
	@"  invoke func1\n"
	@"  invoke func2\n"
	@"\n"
	@"@func1\n"
	@"  assignconst one a\n"
	@"  assignconst two b\n"
	@"\n"
	@"@func2\n"
	@"  assignconst three a\n"
	@"  assignconst four b\n"
	;
	
	NSString *data = @"";
	
	SKEngine *engine = [self runScript:script usingData:data];
	NSString *a = [engine variableFor:@"a"];
	NSString *b = [engine variableFor:@"b"];
	GHAssertEqualStrings(a, @"three", nil);
	GHAssertEqualStrings(b, @"four", nil);
}



@end
