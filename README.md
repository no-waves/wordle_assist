# README

This is a program that uses Wordle guesses and results to help filter for potential solutions.

[play Wordle](https://www.powerlanguage.co.uk/wordle/)


## Install

```
git clone https://github.com/no-waves/wordle_assist
cd wordle_assist
nim c -d:release wordle_assist
./wordle_assist
```


## Playing

Enter your 5 character guess followed by a comma and the results for each character, with:
* y = the character is in the solution and is in the correct position (green in Wordle)
* ? = the character is in the solution but in a different position (yellow in Wordle)
* n = the character is not contained in the puzzle solution (grey in Wordle)

Example: `blast,yn?nn`

The program will print a sequence of potential solutions and ask for the next round of input.


## Notes

The current word list (sourced from [this project](https://github.com/dwyl/english-words/)) contains words not in Wordle's dictionary. Wordle won't accept words not included in its dictionary, though, so you won't lose any guesses. Just don't use any unusual looking options.