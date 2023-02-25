# Check if a year is leap year
def get_leapyear():
    year = int(input("Enter a year : "))
    if year % 4 == 0:
        print(year, 'is a leap year')
    else:
        print(year, 'is not a leap year')


get_leapyear()
