# print("**********************************************************")
# print("Exercise 1: String Manipulation in Python")
# print("**********************************************************")
# n = "rAVI     kUMAR  "
# print(f"Split and Title Result: {n.title().split()}")
# print(f"Join Title and Split Result: {' '.join(n.title().split()) }")


# print("**********************************************************")
# print("Exercise 2: convert string to number")
# print("**********************************************************")
# s = "Rs  1,250.90"
# r = s.replace("Rs", "").replace(",", "").replace(" ", "")
# print(f"Replaced String Result: {r}")
# print(f"converted to float Result: {float(r)}")


# print("**********************************************************")
# print("Exercise 3: Masking Sensitive Information")
# print("**********************************************************")
# mobile = "9573393279"
# print(f"last 4 digits of mobile number: {mobile[-4:]}")
# print(f"masked mobile number: {'*' * 6 + mobile[-4:]}")


# m = "987 6543 2  10   "
# print(m[0])
# print(len(m))
# n = "".join(m.split())
# print(n[0])
# print(len(n))
# if len(n) == 10 and n[0] >= '6' and n[0] <= '9' :
#         print("Valid mobile number")
# else:
#         print("Invalid mobile number")


# m = "987 6543 2  10   "
# n = "".join(m.split())
# o = "*"*6
# print("*"*6+n[-4:])
# print(o.join(n[-4:]))


# numbers = [10, 20, 10, 30, 20, 40, 30]

# deduped_numbers = list(set(numbers))
# print(f"Deduped numbers: {deduped_numbers}")

# fruits = ["apple", "banana", "apple", "orange", "banana", "apple"]
# fruits_set = set(fruits)
# unique_fruit_count = len(fruits_set)
# print(f"Unique fruits: {fruits_set}")
# print(f"Unique fruit count: {unique_fruit_count}")


text = "banana"
alphabets = set(text)
for alphabet in alphabets:
    count = text.count(alphabet)
    print(f"Alphabet: {alphabet}, Count: {count}")

price = "Rs  1,250.90"
split_price = price.split()
print(split_price)
conv_string  = price.replace(",","").replace("Rs","")
rem_chars = conv_string.strip()

print(rem_chars)
price_num = float(rem_chars)
print(price_num)


text = "Snowflake Data Engineering"
text1 = "Snowflake Data Engineering"
text = text.lower()
text = "".join(text.split())
print(f"Stripped String Result: {text}")
text_set = set(text)
print(f"Set Result: {text_set}")

text_sorted = sorted(text_set)
print(f"Sorted Result: {text_sorted}")

tot_count = 0

for char in text_sorted:
    if char in [ 'a', 'e', 'i', 'o', 'u']:
        count = text.count(char)
        print(f"Vowel: {char}, Count: {count}")
        tot_count += count

print(f"Total Vowel Count: {tot_count}")
tot_count = 0

for char in sorted(set("".join(text1.lower().split()))):
    if char in ['a', 'e', 'i', 'o', 'u']:
        count = text1.lower().count(char)
        print(f"Vowel: {char}, Count: {count}")
        tot_count += count

print(f"Total Vowel Count: {tot_count}")

text = "Snowflake"
print(f"Original String: {text}")
rev_string = ""
for char in text[::-1]:
    rev_string += char
print(rev_string)

text = "Madam"
text = text.lower()

rev_text = text[::-1]
print(rev_text)

if (rev_text == text):
    print("text is a palindrome")
else:
    print("Text not palindrome")


sentence = "Snowflake and Python are useful data engineering skills"
sentense_list = sentence.split(" ")
print(sentense_list)

word_count = 0
for words in sentense_list:
    word_count +=1

# word_count  = count(sentense_list)
print(f"Word count in the sentence is {word_count}")
wc = len(sentense_list)
print(wc)


numbers = [-12, -45, 7, -89, -23, -56]

big_num = numbers[0]
small_num = numbers[0]
for num in numbers:
    if num >= big_num:
        big_num = num
    if num < small_num:
        small_num = num
print(f"biggest number in the list is {big_num}")
print(f"smallest number in the list is {small_num}")


numbers = [12, 45, 7, 89, 23, 56, 89, 7, 45, 12,7,89, 7, 12, 89]

print(f"all numbers in the list : {numbers}")

number_set = set(numbers)
print(f"deduplicated number list: {number_set}")
sorted_numbers = sorted(number_set)

print(f"Sorted List {sorted_numbers}")
print(f"second largest number in list is {sorted_numbers[1]}")

numbers = [12, 45, 7, 89, 23, 56, 90, 31, 44]

even_num = odd_num = 0

for num in numbers:
    if num % 2 == 0:
        even_num +=1
    else:
        odd_num +=1

print(f"Even number count : {even_num} , odd number count: {odd_num}")

list1 = [1, 2, 3, 4, 5, 6]
list2 = [4, 5, 6, 7, 8, 9]

set1 = set(list1)
set2 = set(list2)

common_set = set1.intersection(set2)
common_list = list(common_set)
print(common_list)


exclusive_set  = set1.difference(set2)
exclusive_list = list(exclusive_set)
print(f"Exclusive elements of List1: {exclusive_list}")

str1 = "Listen"
str2 = "Silent"

sorted_string1 = sorted(str1.lower())
sorted_string2 = sorted(str2.lower())

print(sorted_string1, sorted_string2)
if sorted_string1 == sorted_string2:
    print("Anagram")
else:
    print("not anagram")

text = "aaabbbbbcdeff"

for alpha in text:
    # print(alpha, text.count(alpha))
    if text.count(alpha) == 1:
        print(alpha)
        break

text = "abccdeff"

for alpha in text:
    print(f"{alpha} count : {text.count(alpha)}")
    if text.count(alpha) > 1 :
        print(alpha)
        break

sentence = "python sql python snowflake sql python"
sentence_set   = set(sentence.split(" "))
# print(sentence_set)
unique_list = sentence.split(" ")
print(unique_list)
for words  in sentence_set:
    print(f"{words} : {unique_list.count(words)}")


text = "succccessssfulliiiiiy"
text_set = set(text)
text_list  = sorted(list(text_set))
# print(text_list)
new_list_chars = list()
new_list_nums = list()
for alpha in text_list:
    new_list_chars.append(alpha)
    new_list_nums.append(text.count(alpha))

# print(new_list_chars)
# print(new_list_nums)
new_list = [list(item) for item in zip(new_list_chars, new_list_nums)]
print(new_list)

biggest_num = max(row[1] for row in new_list)
# print(biggest_num)

for alpha in new_list:
    # print(alpha[1])
    if alpha[1] == biggest_num:
        print(alpha)
        # break


text = "succccessssfulliiiiiy"

unique_char_set = set(text)
print(f"unique charecters in the word are: {unique_char_set}")

text_char = list()
char_num = list()

for alphabet in unique_char_set:
    # print(f"{alphabet} count: {text.count(alphabet)}")
    text_char.append(alphabet)
    char_num.append(text.count(alphabet))
# print(text_char)
# print(char_num)

text_2d = [list(item) for item in zip(text_char, char_num)]
print(text_2d)

biggest_num = max(num[1] for num in text_2d)
# print(biggest_num)

for alpha in text_2d:
    if alpha[1] == biggest_num:
        print(alpha)
numbers = [4, 2, 4, 7, 2, 4, 9, 2, 4, 7, 7]

number_set = set(numbers)
# print(number_set)

num_key = list()
num_value = list()


for num in number_set:
    num_key.append(num)
    num_value.append(numbers.count(num))

print(num_key)
print(num_value)

# text_2d = [list(item) for item in zip(num_key, num_value)]
d_num = [list(nums) for nums in zip(num_key,num_value)]
# print(text_2d)
print(d_num]]