# Code to figure armstrong numbers
def check_armstronginterval():
    lower=int(input("Enter lower limit"))
    upper = int(input("Enter upper limit"))

    for number in range(lower,upper+1,1):
        sum=0
        for i in str(number):
            sum+=int(i)*int(i)*int(i)
        if number == sum:
            print(number)
