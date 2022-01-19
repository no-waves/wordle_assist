# Program that uses Wordle guesses and results to help filter for potential solutions
# See Wordle at https://www.powerlanguage.co.uk/wordle/

import std/[strutils,re]

# Word source: https://github.com/dwyl/english-words/
const filename = "words_alpha.txt"
const wordsource = staticRead(filename) # Compiles with txt file
const test_regex = false # Compile set to true to print regex stuff for testing
const word_length = 6 # 5 chars + return char

var knownPositions = [".",".",".",".","."] # Set default to "." to help with regex
var badPositions = [".",".",".",".","."] # Set default to "." to help with regex
var badLetters: seq[string] # Append bad letters as identified
var goodLetters: seq[string] # Append good letters as identified


# Generate word list from word txt
proc generateWordList(): seq[string] =
    var word_list: seq[string]
    for line in wordsource.split("\n"):
        if line.len == word_length:
            word_list.add(line.strip.toUpper)
    result = word_list

# Generate regex string for known letter positions
proc knownPositionRegex(n: array[5,string]): string =
    var regexStr: string
    for letter in n:
        regexStr.add(letter)
    result = regexStr

# Generate regex string for loose letters
proc looseLetterRegex(n: seq[string]): string =
    var regexStr: string
    for letter in n:
        if regexStr.len == 0:
            regexStr.add(letter)
        elif not regexStr.contains(letter):
            regexStr.add("|" & letter)
        else:
            discard
    regexStr = "[" & regexStr & "]"
    result = regexStr

# Generate regex string for known bad positions
proc badPositionRegex(n: array[5,string]): string =
    var regexStr: string
    for position in n:
        var tempStr = position
        if tempStr == ".":
            regexStr.add(tempStr)
        else:
            regexStr.add("[^" & tempStr & "]")
    result = regexStr

# Check if all good characters are contained in a word
proc looseLetterCheck(n: string): bool =
    var i = 0
    for letter in goodLetters:
        if n.contains(letter):
            inc i
    if i == goodLetters.len:
        return true
    else:
        return false

# Match regex expressions against word list to get possible solutions
proc runRegex(wordlist: seq[string], knownGoodPositions, knownBadPositions, badLetters: Regex): seq[string] =
    var options: seq[string]
    for word in wordlist:
        if word.match(knownGoodPositions) and
        word.match(knownBadPositions) and
        not word.contains(badLetters) and
        looseLetterCheck(word):
            options.add(word)
    result = options

# Get and process guess and response input
proc getInput(): bool =
    let char_limit = word_length - 1
    var loop = true
    var response: string
    var response_result: string
    while loop:
        echo "\nEnter guess and results (y=known, n=bad, ?=wrong position)"
        echo "Example: abcde,?nyn? (or exit to quit)"
        let input = readLine(stdin)
        if input.toLower == "exit":
            quit()
        var linecount = 0
        
        for line in input.split(","):
            if linecount == 0:
                response = line.toUpper
            elif linecount == 1:
                response_result = line.toLower
            else:
                echo "**discarding " & line & "***"
            inc linecount
        if response_result == "yyyyy":
            echo "\n\"" & response & "\""
            quit()
        if response.len == char_limit and response_result.len == char_limit:
            loop = false
        else:
            echo "[error] Response and result must each be " & $char_limit & " characters"
            loop = true

    var i = 0
    for r in response_result:
        if r == 'y':
            var tempStr = $response[i]
            knownPositions[i] = tempStr
        elif r == '?':
            var tempStr = $response[i]
            if not goodLetters.contains(tempStr):
                goodLetters.add(tempStr)
            if badPositions[i] == ".":
                badPositions[i] = tempStr
            else:
                badPositions[i].add("|" & tempStr)
        elif r == 'n':
            var tempStr = $response[i]
            if not knownPositions.contains(tempStr) and
            not goodLetters.contains(tempStr):
                badLetters.add(tempStr)
            elif badPositions[i] == ".":
                badPositions[i] = tempStr
            else:
                badPositions[i].add("|" & tempStr)
        inc i
    return true
 
when isMainModule:
    let wordlist = generateWordList()
    var guess = 0
    while guess < 5:
        discard getInput()
        inc guess
        var knownGoodRegex = knownPositionRegex(knownPositions)
        var knownBadRegex = badPositionRegex(badPositions)
        var badLetterRegex = looseLetterRegex(badLetters)
        when test_regex: # Print regex info if compiled as true
            var goodLetterRegex = looseLetterRegex(goodLetters)
            echo "knownGood regex: " & knownGoodRegex
            echo "knownBad regex: " & knownBadRegex
            echo badPositions
            echo "badLetter regex: " & badLetterRegex
            echo "goodLetter regex: " & goodLetterRegex
            echo goodLetters
            echo "goodLetters.len: " & $goodLetters.len
            echo "press enter to continue"
            discard readLine(stdin)
        let output = runRegex(wordlist, re(knownGoodRegex), re(knownBadRegex), re(badLetterRegex)) # Convert regex strings to Regex types
        echo ""
        echo output
        if output.len == 1:
            quit()