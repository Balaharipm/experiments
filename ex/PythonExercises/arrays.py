array2d = [[1,2,3], [1,2,3]]

i = 1
for y in range (0,2):
    for x in range(0,3):
        array2d[y][x] += i

print(array2d)
#array2d = [[1, 2, 3] for _ in range(3)]
# array2d = [
#     [1,2,3],
#     [4,5,6],
#     [7,8,9]
#     ]

# #array2d = [[' ' for _ in range(3)] for _ in range(3)  ]
# x=1
# array2d = [[i for i in range(x+y*3,x+y*3+3)] for y in range(0,3)  ]
# i = 1
# array2d = [[i, i+1, i+3]]
# for row in array2d:
#     print(row)

# example_blueprint.py
# from flask import Blueprint

# example_blueprint = Blueprint('example_blueprint', __name__)

# @example_blueprint.route('/')
# def index():
#     return "This is an example app"