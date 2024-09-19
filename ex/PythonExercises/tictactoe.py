board = [[' ' for _ in range(3)] for _ in range(3)]
players = ('o','x')

def fill_board(position: int, player):
    if(int(position) > 8 or int(position) < 0):
        raise Exception("Please select valid position")
    else:
        pos_x = position % 3
        pos_y = position // 3
        if (board[pos_y][pos_x] == ' '):
            board[pos_y][pos_x] = player
        else:
            raise Exception("Spot taken. Please select a different position.")
    
    

        
def check_game_end(player):
    
    #for player in players:
    is_game_end = True
    for x in range(3):
    #Check horizontal win condition for player
        if all(board[x][j] == player for j in range(3)):
            return player
    #Check vertical win condition for player
    for x in range(3):
        is_game_end = True
        for y in range(3):
            is_game_end &= (board[y][x] == player)
        if(is_game_end):
            return player # winner
    #Check the \ diagonal win condition for player
    if (board[0][0] == player and board[1][1] == player and board[2][2] == player):
            return player # winner
    #Check the / diagonal win condition for player
    if (board[0][2] == player and board[1][1] == player and board[2][0] == player):
            return player # winner
    #Check for tie
    for x in range(3):
        for y in range(3):
            if(board[y][x] == ' '):
                return None #Still player turn available
    return 'Nobody... it was a Tie' #Tie

def turn_input(player: str):
    return int(input (f'[0|1|2]\n[3|4|5]\n[6|7|8]\nEnter the position where to fill {player} (int 1-9)? '))
    
def board_to_str():
    return_string = ''
    for row in board:
        return_string += '['
        for i in range(3):
            return_string += str(row[i])
            if i != 2:
                return_string += '|'
        return_string += ']\n'
    return return_string

def do_turn(player):
    while True:
        print(board_to_str())
        try:
            fill_board(turn_input(player), player)
        except Exception as e:
            print(e)
        else:
            break
    
        
if __name__== "__main__": # Main
    print("Welcome to Tic Tac Toe! \n Pick the player to start the game: x or o")
    player = input()
    if player == 'x' or player == 'o':
        while True: 
            do_turn(player)
            if (check_game_end(player) != None):
                break
            if player == 'x':
                player = 'o'
            else:
                player = 'x'
    print("And the winner is... " + str(check_game_end(player)))
    
    
            
            

        
        
    