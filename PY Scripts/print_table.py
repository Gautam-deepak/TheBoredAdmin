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

table()