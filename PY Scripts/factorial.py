#using logic

def factorial():
    factorial=1
    number=int(input("Enter a number"))
    if number==0:
        print("Factorial of 0 is 1")
    else:
        for i in range(1,number+1,1):
            factorial=factorial*i
    print('Factorial of', number, 'is', factorial)
    #return factorial

# using math function

import math
number=int(input("Enter a number"))
factorial=math.factorial(number)
print(factorial)
