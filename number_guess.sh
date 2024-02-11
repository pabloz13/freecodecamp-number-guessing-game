#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# check if the user exists
USERNAME_AVAILABILITY=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ ! -z $USERNAME_AVAILABILITY ]]
# if the user exists
then
  # get number of games the user has played and their best game
  NUMBER_GAMES_RESULT=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME_RESULT=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $NUMBER_GAMES_RESULT games, and your best game took $BEST_GAME_RESULT guesses."
# if the user doesn't exist
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  NUMBER_GAMES_RESULT=0
fi

# start the game
SECRET_NUMBER=$((1 + RANDOM % 1000))
echo $SECRET_NUMBER
GUESSES=1
echo "Guess the secret number between 1 and 1000:"

# loop reading the input
while read NUMBER_USER
do
  # check if it's an integet
  if [[ ! $NUMBER_USER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $NUMBER_USER < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $NUMBER_USER > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $NUMBER_USER == $SECRET_NUMBER ]]
  then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
  ((GUESSES++))
done

# check if it's a best game
if [[ $NUMBER_GAMES_RESULT > 0 ]]
then
  # add a game to number of games
  ((NUMBER_GAMES_RESULT++))
  # compare this try to the best result
  if [[ $GUESSES < $BEST_GAME_RESULT ]]
  then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE username = '$USERNAME'")
    UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = $NUMBER_GAMES_RESULT WHERE username = '$USERNAME'")
  else
    UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET games_played = $NUMBER_GAMES_RESULT WHERE username = '$USERNAME'")
  fi
else
  # add the user to the table
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESSES)")
fi
