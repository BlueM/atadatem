#import <Foundation/Foundation.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void clean(const char *fspath, BOOL testMode,
		   BOOL removeDSStore, BOOL removeSVNDirs,
		   BOOL removeGitDirs, BOOL removeIcons);

void help();

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	static char options[] = "adshgit";
	BOOL removeDSStore = NO;
	BOOL removeGitDirs = NO;
	BOOL removeSVNDirs = NO;
	BOOL removeIcons   = NO;
	BOOL testMode      = NO;
	unsigned int i, optchar;
	
	// Parse command line options
	while ((optchar = getopt(argc, (char * const *)argv, options)) != -1) {
		
		switch(optchar) {

			case 'h':
				help();
				[pool release];
				return EXIT_SUCCESS;
				
			case 'a':
				removeDSStore = YES;
				removeGitDirs = YES;
				removeSVNDirs = YES;
				removeIcons   = YES;
				break;
				
			case 's':
				removeSVNDirs = YES;
				break;
				
			case 't':
				testMode = YES;
				break;
				
			case 'i':
				removeIcons = YES;
				break;
				
			case 'g':
				removeGitDirs = YES;
				break;
				
			case 'd':
				removeDSStore = YES;
				break;
				
		}
	}
	
	if (argc == optind) {
		// No arguments given
		help();
		[pool release];
		return EXIT_SUCCESS;
	}
	
	// Loop over remaining arguments
	for (i = optind; i < argc; i ++) {
		clean(argv[i], testMode, removeDSStore, removeSVNDirs, removeGitDirs, removeIcons);
	}

	[pool release];
    return 0;
}


void clean(const char *fspath, BOOL testMode,
		   BOOL removeDSStore, BOOL removeSVNDirs,
		   BOOL removeGitDirs, BOOL removeIcons) {

 	NSFileManager *fMan = [NSFileManager defaultManager];
	NSString *path = [fMan stringWithFileSystemRepresentation:fspath length:strlen(fspath)];
 	NSString *item;
 	BOOL isDir;
 
 	// Silently ignore anything that's not a directory
 	if ([fMan fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
 		return;
 	}

	NSDirectoryEnumerator *dEnum = [fMan enumeratorAtPath:path];

	NSMutableArray *removeDirs  = [NSMutableArray arrayWithCapacity:4];
	if (removeSVNDirs) [removeDirs  addObject:@".svn"];
	if (removeGitDirs) [removeDirs  addObject:@".git"];
	
	NSMutableArray *removeFiles = [NSMutableArray arrayWithCapacity:4];	
	if (removeDSStore) [removeFiles addObject:@".DS_Store"];
	if (removeIcons)   [removeFiles addObject:@"Icon\r"];
		
 	while (item = [dEnum nextObject]) {
		NSString *name = [item lastPathComponent];
		if ([removeDirs containsObject:name]) {
			NSString *subPath = [path stringByAppendingPathComponent:item];
			if ([fMan fileExistsAtPath:subPath isDirectory:&isDir] && isDir) {
				if (testMode) {
					printf("%s\n", [subPath UTF8String]);
				} else {
					[fMan removeFileAtPath:subPath handler:nil];
				}
			}
		} else if ([removeFiles containsObject:name]) {
			NSString *subPath = [path stringByAppendingPathComponent:item];
			NSDictionary *attributes = [fMan attributesOfItemAtPath:subPath error:nil];
			if ([NSFileTypeRegular isEqualToString:[attributes objectForKey:NSFileType]]) {
				if (testMode) {
					printf("%s\n", [subPath UTF8String]);
				} else {
					[fMan removeFileAtPath:subPath handler:nil];
				}
			}
		}
 	}
}

void help() {
	char *date = __DATE__;
	NSString *dateString = [NSString stringWithCString:date encoding:NSUTF8StringEncoding];
	NSDate *dateobj = [NSDate dateWithNaturalLanguageString:dateString];
	NSString *mdy = [dateobj descriptionWithCalendarFormat:@"%m/%d/%Y" timeZone:nil locale:nil];
	printf("\n");
	printf(" atadatem removes specific metadata from directories\n\n");
	printf(" Usage: \n");
	printf("   atadatem [-a -d -i -s -g] path1 [path2] [...]\n\n");
	printf(" Options: \n");
	printf("   -d  Recursively remove .DS_Store files\n");
	printf("   -i  Recursively remove Mac Icon files (“Icon\\r”)\n");
	printf("   -s  Recursively remove .svn directories\n");
	printf("   -g  Recursively remove .git directories\n");
	printf("   -a  Recursively remove all of the above\n");
	printf("   -t  Test mode: prints files/directories that would have been\n");
	printf("       deleted, but does not delete anything.\n");
	printf("\n");
	printf(" atadatem 1.0\n");
	printf(" Carsten Bluem, %s\n", [mdy UTF8String]);
	printf(" Website: www.bluem.net\n\n");
}

