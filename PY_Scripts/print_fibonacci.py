# write a code to print fibonacci numbers
number=[]
number.append(1)
number.append(1)
upper=int(input("enter the upper limit for fibonacci numbers"))
for i in range(2,upper):
    number.append(number[i-1]+number[i-2])
print(number)