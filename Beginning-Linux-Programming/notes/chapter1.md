# Chapter 1: Getting Started
## UNIX Philosophy 
"Although programming in C is in many ways the same whatever the platform, UNIX and Linux developers have a special view of program and system development."

### The characters of UNIX programs and system
- Simplify: KISS -> "Keep It Small and Simple"
- Focus: Programs with a single purpose are easier to improve as better algorithms or interface are developed 
- Reusable Components: Make your code of your application available as a library
- Filters: UNIX applications can be used as filters.
- Open File Formats: The more successful and popular UNIX programs use configuration files and data files that are plain ASCII text or XML.
- Flexibility: Try to be as flexible as possible in your programming. Try to avoid arbitrary limits on field sizes or number of records.
## What is Linux?
Linux is a freely distributed implementation of a UNIX-like kernel,the low level core of an operating system

## Programming Linux 
It is true that UNIX was originally written in C and that majority of UNIX applications are written in C, but C is not the only option available to Linux programmers, or UNIX programmers for the matter.

## Linux Programs
Linux applications are represented by two special types of files: *executables* and *scripts*.  
**Executable:** files are programs that can be run directly by the computer;  
**Script:** collections of instructions for another program.  
### Usual search paths 
- /bin: Binaries, programs used in booting the system
- /usr/bin: User binaries, standard programs available to users 
- /usr/local/bin: Local binaries, program specific to installation.  
**It is not a good idea to delete dictionaries from PATH unless you are sure that you under what will result if you do.**  
uses the colon (:) character to separate entries in the PATH variable

## The C Compiler
### Code with Vim
open file: `vim filename`  
save file: `:w`  
quit: `:q`  
switch to writing mode: `:i`  

### Use gcc to compile, link and run the program
```
    gcc -o programname sourcecodename
    ./programname
```
### How it works 
You invoked the GNU C compiler that translated the C source into an executable file call *filename*. Then you ran the program and it print a greeting.  

Prefix program names with `./ `(for example, `./hello`). This specifically instructs the shell to execute the program in the current directory with the given name. (The dot is an alias for the current directory.)
