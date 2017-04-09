/**
 * Copyright (c) 2012-2017, Carsten Blüm <carsten@bluem.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * - Neither the name of Carsten Blüm nor the names of his contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void clean(const char *fspath, BOOL testMode, BOOL removeDSStore, BOOL removeSvn,
           BOOL removeGit, BOOL removeIcons, BOOL removeJs, BOOL removeEditor, BOOL removeTools);

void help();

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    static char options[] = "adcsjhegit";
    BOOL removeDSStore = NO;
    BOOL removeGit     = NO;
    BOOL removeJs      = NO;
    BOOL removeEditor  = NO;
    BOOL removeSvn     = NO;
    BOOL removeIcons   = NO;
    BOOL removeTools   = NO;
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
                removeGit     = YES;
                removeSvn     = YES;
                removeJs      = YES;
                removeIcons   = YES;
                removeEditor  = YES;
                removeTools   = YES;
                break;
            case 'j':
                removeJs = YES;
                break;
            case 'e':
                removeEditor = YES;
                break;
            case 's':
                removeSvn = YES;
                break;
            case 't':
                testMode = YES;
                break;
            case 'c':
                removeTools = YES;
                break;
            case 'i':
                removeIcons = YES;
                break;
            case 'g':
                removeGit = YES;
                break;
            case 'd':
                removeDSStore = YES;
                break;
            default:
                printf("Invoke with -h to see the help\n");
                return EXIT_FAILURE;
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
        clean(argv[i], testMode, removeDSStore, removeSvn, removeGit, removeIcons, removeJs, removeEditor, removeTools);
    }

    [pool release];
    return 0;
}


void clean(const char *fspath, BOOL testMode, BOOL removeDSStore, BOOL removeSvn,
           BOOL removeGit, BOOL removeIcons, BOOL removeJs, BOOL removeEditor, BOOL removeTools) {

    NSFileManager *fMan = [NSFileManager defaultManager];
    NSString *path = [fMan stringWithFileSystemRepresentation:fspath length:strlen(fspath)];
    NSString *item;
    BOOL isDir;

    // Silently ignore anything that's not a directory
    if ([fMan fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
        return;
    }

    NSMutableArray *removeDirs  = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray *removeFiles = [NSMutableArray arrayWithCapacity:4];

    if (removeSvn) {
        [removeDirs addObject:@".svn"];
    }

    if (removeGit) {
        [removeDirs addObject:@".git"];
        [removeFiles addObject:@".gitkeep"];
        [removeFiles addObject:@".gitignore"];
        [removeFiles addObject:@".gitattributes"];
        [removeFiles addObject:@".gitmodules"];
    }

    if (removeEditor) {
        [removeDirs addObject:@".idea"];
        [removeFiles addObject:@".editorconfig"];
    }

    if (removeTools) {
        [removeFiles addObject:@".travis.yml"];
        [removeFiles addObject:@".scrutinizer.yml"];
        [removeFiles addObject:@".coveralls.yml"];
        [removeFiles addObject:@".codeclimate.yml"];
    }
    
    if (removeDSStore) {
        [removeFiles addObject:@".DS_Store"];
    }

    if (removeJs) {
        [removeFiles addObject:@".jshintrc"];
        [removeFiles addObject:@".jslintrc"];
        [removeFiles addObject:@".babelrc"];
        [removeFiles addObject:@".eslintrc.js"];
        [removeFiles addObject:@".eslintrc.yaml"];
        [removeFiles addObject:@".eslintrc.yml"];
        [removeFiles addObject:@".eslintrc.json"];
        [removeFiles addObject:@".eslintrc"];
        [removeFiles addObject:@".eslintignore"];
    }

    if (removeIcons) {
        [removeFiles addObject:@"Icon\r"];
    }

    NSDirectoryEnumerator *dEnum = [fMan enumeratorAtPath:path];
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
    NSString *help = @"\n"
    "atadatem recursively removes specific invisible metadata files/directories\n\n"
    "Usage: \n"
    "  atadatem [-a -d -i -s -g] path1 [path2] [...]\n\n"
    "Options: \n"
    "  -d  Recursively remove .DS_Store files\n"
    "  -i  Recursively remove Mac Icon files (“Icon\\r”)\n"
    "  -g  Recursively remove Git-related metadata: .git, .gitattributes, .gitmodules, .gitignore, .gitkeep\n"
    "  -s  Recursively remove Subversion .svn directories\n"
    "  -j  Recursively remove JavaScript-related metadata: .jshintrc, .jslintrc, .babelrc, .eslintrc, .eslintrc.*, .eslintignore\n"
    "  -e  Recursively remove editor/IDE metadata: .idea, .editorconfig\n"
    "  -c  Recursively remove integration/analysis tools’ metadata: .travis.yml, .scrutinizer.yml, .coveralls.yml, .codeclimate.yml\n"
    "  -a  Recursively remove all of the above\n"
    "  -t  Test mode: removes nothing, only reports which files/directories would be deleted\n"
    "\n"
    "atadatem 2.0\n"
    "Carsten Bluem, 03/07/2017\n"
    "Website: www.bluem.net/jump/atadatem\n";

    printf("%s", [help UTF8String]);
}
