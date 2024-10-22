# Homework 7: Linux CLI commands

## Overview

The goal of this homework is to become more familiar with linux commands in the CLI. This includes counting words, sorting, cutting,grep, regex, and redirection.

##

### Problem 1
 `wc -w lorem-ipsum.txt`
![HW7 Problem 1](/docs/assets/HW7/problem1.png)

### Problem 2
`wc -c lorem-ipsum.txt` 
![HW7 Problem 2](/docs/assets/HW7/problem2.png)

### Problem 3
`wc -l lorem-ipsum.txt` 
![HW7 Problem 3](/docs/assets/HW7/problem3.png)

### Problem 4
`sort -h file-sizes.txt` 
![HW7 Problem 4](/docs/assets/HW7/problem4.png)

(screenshot is cut off, but this is the last of the output)

### Problem 5
`sort -h -r -u file-sizes.txt`
![HW7 Problem 5](/docs/assets/HW7/problem5.png)

(-u was used to see the unique values, otherwise this screenshot was just filled with multiple copies of zero)

### Problem 6
`cut -d , -f 3 log.csv` 

![HW7 Problem 6](/docs/assets/HW7/problem6.png)

### Problem 7
`cut -d , -f 2-3 log.csv`

![HW7 Problem 7](/docs/assets/HW7/problem7.png)

### Problem 8
`cut -d , -f 1,4 log.csv` 

![HW7 Problem 8](/docs/assets/HW7/problem8.png)

### Problem 9
`head -n 3 gibberish.txt` 
![HW7 Problem 9](/docs/assets/HW7/problem9.png)

### Problem 10
`tail -n 2 gibberish.txt` 
![HW7 Problem 10](/docs/assets/HW7/problem10.png)

### Problem 11
`tail -n 20 log.csv` 
![HW7 Problem 11](/docs/assets/HW7/problem11.png)

### Problem 12
`grep and gibberish.txt` 
![HW7 Problem 12](/docs/assets/HW7/problem12.png)

### Problem 13
`grep -w -n we gibberish.txt` 
![HW7 Problem 13](/docs/assets/HW7/problem13.png)

### Problem 14
`grep -P -o -i '(to\s\w+)' gibberish.txt` 
![HW7 Problem 14](/docs/assets/HW7/problem14.png)

### Problem 15
`grep -c 'FPGAs' fpgas.txt` 
![HW7 Problem 15](/docs/assets/HW7/problem15.png)

### Problem 16
`grep -P '[hn]ot|[ct]ower|[smcomp]ile' fpgas.txt` 
![HW7 Problem 16](/docs/assets/HW7/problem16.png)

### Problem 17
`grep -P -r -c "^\s*--" .` 
![HW7 Problem 17](/docs/assets/HW7/problem17.png)

(The only place I have lines that start with comments is in LED_Patterns.vhd)

### Problem 18
`ls > ls-output.txt` 
![HW7 Problem 18](/docs/assets/HW7/problem18.png)

### Problem 19
`sudo dmesg | grep 'CPU'` 
![HW7 Problem 19](/docs/assets/HW7/problem19.png)

### Problem 20
`find hdl -iname '*.vhd' | wc -l` 
![HW7 Problem 20](/docs/assets/HW7/problem20.png)

### Problem 21
`grep -P -r "^\s*--" . | wc -l` 
![HW7 Problem 21](/docs/assets/HW7/problem21.png)

### Problem 22
`grep -i -n fpgas fpgas.txt | cut -b ` 
![HW7 Problem 22](/docs/assets/HW7/problem22.png)

### Problem 23
`du -h * | sort -h -r -u | head -n 3 ` 
![HW7 Problem 23](/docs/assets/HW7/problem23.png)





