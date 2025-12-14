~~~
x16emu -gs -scale 2 -quality linear -fsroot /mnt/c/x16emu_win64-r49/drive -rtc -debug
~~~

# Things to Do
* Unit Tests for Malloc
* Print string routines
* Code to dump malloc structures for debugging
* Simplify macros
* Make private functions "near"
* Implement macros for
    * Relocatable JSR
    * Relocatable JSL
    * JSR(Address)
    * JSL(Address)
    * JSR(Address),x
    * JSL(Address),x    
    * JSR[Address]
    * JSL[Address]
    * JSR[Address],x
    * JSL[Address],x    
* Protocol for writing DLL's
    * All code must be relocatable
    * DLL must fit entirely within 64k
    * All calls to DLL must be far calls
    * DLL loader must create a table of function pointers at it's load address so you effectively "JSL[{LoadAddress}],X" where X = function Number
# x16gs-test
