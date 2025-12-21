# x16gs-test

## To Test
~~~
x16emu -gs -scale 2 -quality linear -fsroot /mnt/c/x16emu_win64-r49/drive -rtc -debug
~~~

## Things to Do
* Make private functions "near"
* 3rd malloc allocates between 1st and 2nd

## CoPilot Prompt to Profile the code
Select all of the sym files first then give these prompts:
~~~
Give me a table of byte count, approximate cycle count, and approximate runningtime in ms for each function in this file.

Can you format this in a seperate table for each file, format it as markup, and add it to "profile.md" in the root of the project?
~~~


