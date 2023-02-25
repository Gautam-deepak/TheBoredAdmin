# Code to figure armstrong numbers
def print_sumofdigits():
    number=int(input("Enter a number"))
    sum=0
    for i in str(number):
         sum+=int(i)
    print(sum)
