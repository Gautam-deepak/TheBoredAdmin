import calendar

mylist = []
mylist.append(1)
mylist.append(2)
mylist.append(3)
print(mylist[0])  # prints 1
print(mylist[1])  # prints 2
print(mylist[2])  # prints 3

# prints out 1,2,3
for x in mylist:
    print(x)

numbers = []
strings = []
names = ["John", "Eric", "Jessica", "Nova"]

# write your code here
second_name = None

# this code should write out the filled arrays and the second name in the names list (Eric).
print(numbers)
print(strings)
print("The second name on the names list is %s" % second_name)

def table():
    num = None
    while num != 0:
        num = float(input("enter a number : "))
        if num == 0:
            print("Enter a number other than 0")
            break
        else:
            for i in range(1, 11, 1):
                print(num, 'x', i, '=', num * i)
                continue

import calendar
