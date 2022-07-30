
def primenumber():
    num = int(input("enter a number : "))
    if num == 2 or num == 3:
        print("Entered number is a prime number")

    elif num == 1:
        print("Entered number is 1 and it is a natural number")

    else:
        for n in range(2,int(num/2)+1,1):
            if num%n == 0:
                print("Entered number is not prime number")
                break
        else:
            print("Entered number is a prime number")







