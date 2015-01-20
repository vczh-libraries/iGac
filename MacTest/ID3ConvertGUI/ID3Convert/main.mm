//
//  main.cpp
//  ID3Convert
//
//  Created by Robert Bu on 1/20/15.
//  Copyright (c) 2015 Robert Bu. All rights reserved.
//

#include <iostream>
#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

#include "ID3Convert.h"

void print_usage()
{
    printf("Usage: id3c [-s=SOURCE_ENCODING_ID] [-t=TARGET_ENCODING_ID] [-d=DEST] folders or files\n  Options:\n    -l:  List available encodings and IDs\n    -h:  Print usage\n    -s:  Source encoding id, default is GBK_18030_2000\n    -t:  Destination encoding id, default is UTF8\n    -d:  Destination folder, default is SRC_FOLDER/id3c\n    -o: Overwrite original file, default is no\n");
}

void print_encodings()
{
    uint32_t num_encodings;
    id3c::CFEncodingInfo* encodings = id3c::GetEncodingList(num_encodings);
    for(int i=0; i<num_encodings; ++i)
    {
        printf("%ld - %s\n", encodings[i].v, encodings[i].name);
    }
    printf("\n");
}

bool ConvertOne(NSString* file, NSString* targetDir)
{
    if(targetDir)
    {
        NSString* targetFile = [targetDir stringByAppendingPathComponent:[file lastPathComponent]];
        if(![[NSFileManager defaultManager] copyItemAtPath:file toPath:targetFile error:0])
        {
            return false;
        }
        file = targetFile;
    }
    
    return id3c::ConvertFileID3Encoding([file UTF8String], -1);
}

int main(int argc, const char * argv[])
{
    if(argc == 1)
    {
        print_usage();
    }
    long encoding = -1;
    long target_encoding = -1;
    
    NSString* target_folder = 0;
    bool overwrite_files = false;
    
    for(int i=1; i<argc; ++i)
    {
        const char* arg = argv[i];
        if(arg[0] == '-')
        {
            size_t len = strlen(arg);
            if(len >= 2)
            {
                if(arg[1] == 's' || arg[1] == 't')
                {
                    if(arg[2] == '=' && len > 3)
                    {
                        if(arg[1] == 's')
                            encoding = atoi(arg+3);
                        else
                            target_encoding = atoi(arg+3);
                    }
                    else
                    {
                        printf("Invalid encoding arg\n");
                        return -1;
                    }
                }
                else if(arg[1] == 'h')
                {
                    print_usage();
                    return 0;
                }
                else if(arg[1] == 'l')
                {
                    print_encodings();
                    return 0;
                }
                else if(arg[1] == 'o')
                {
                    overwrite_files = true;
                }
                else if(arg[1] == 'd' && len > 3)
                {
                    target_folder = [[NSString alloc] initWithUTF8String:arg+3];
                }
            }
        }
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if(target_folder)
    {
        if(![fm createDirectoryAtPath:target_folder withIntermediateDirectories:YES attributes:0 error:0])
        {
            NSLog(@"Failed to create output folder\n");
            return -1;
        }
    }
    
    for(int i=1; i<argc; ++i)
    {
        if(argv[i][0] != '-' && argv[i][0] != '.')
        {
            BOOL isDirectory;
            
            NSString* file;
            NSString* ns_path = [[NSString alloc] initWithUTF8String:argv[i]];
            
            [[NSFileManager defaultManager] fileExistsAtPath: ns_path
                                                 isDirectory: &isDirectory];;
            
            if(isDirectory)
            {
                NSDirectoryEnumerator* enumerator = [fm enumeratorAtPath:ns_path];
                
                NSString* tmp_target = target_folder;
                if(!tmp_target && !overwrite_files)
                {
                    tmp_target = [ns_path stringByAppendingPathComponent:@"id3c"];
                    if(![fm createDirectoryAtPath:tmp_target withIntermediateDirectories:YES attributes:0 error:0])
                    {
                        NSLog(@"Failed to create output folder\n");
                        return -1;
                    }
                }
                
                while (file = [enumerator nextObject])
                {
                    BOOL isDirectory = NO;
                    NSString* full_path = [NSString stringWithFormat:@"%@/%@", ns_path, file];
                    [[NSFileManager defaultManager] fileExistsAtPath: full_path
                                                         isDirectory: &isDirectory];
                    if (!isDirectory)
                    {
                        if([file characterAtIndex:0] != '.' &&
                           [[file pathExtension] isEqualToString:@"mp3"])
                        {
                            if(!ConvertOne(full_path, tmp_target))
                            {
                                NSLog(@"Failed to convert: %@", file);
                            }
                            else
                            {
                                NSLog(@"Saved: %@", file);
                            }
                        }
                    }
                }
            }
            else
            {
                file = [NSString stringWithUTF8String:argv[i]];
                
                NSString* tmp_target = target_folder;
                if(!tmp_target && !overwrite_files)
                {
                    tmp_target = [[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"id3c"];
                    if(![fm createDirectoryAtPath:tmp_target withIntermediateDirectories:YES attributes:0 error:0])
                    {
                        NSLog(@"Failed to create output folder\n");
                        return -1;
                    }
                }
                if(!ConvertOne(file, tmp_target))
                {
                    NSLog(@"Failed to convert: %@", file);
                }
                else
                {
                    NSLog(@"Saved: %@", file);
                }
            }
        }
        
    }
    
}
