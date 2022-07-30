# Code to figure armstrong numbers
def check_armstrong():
    number = int(input("Enter a number"))
    sum = 0
    for i in str(number):
         sum+=int(i)*int(i)*int(i)
    if number==sum:
        print("Entered number is an armstrong number")
    else:
        print("Entered number is not an armstrong number")


