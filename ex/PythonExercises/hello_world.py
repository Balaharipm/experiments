a=0
b=0
a = input("Enter the first number: ")
b = input("Enter the second number: ")
print("Hello, I can compute the sum of two numbers.", int(a)+int(b))
print("This ia a quote from me: \"I am a computer programmer\"")

#Number 8 as output for the sum, difference, product of two integers

output = 8
for x in range (1, 8):
    for y in range (1,8):
#Addition:
        if (x + y == output):
            print(f"The sum of the two numbers {x},{y} is 8")
#Product:
        if (x * y == output):
            print(f"The product of the two numbers {x},{y} is 8")
#Subtraction:
        if (x - y == output):
            print(f"The difference of the two numbers {x},{y} is 8")                  
#Division:
        if (x / y == output):
            print(f"The quotient of the two numbers {x},{y} is 8")           
            