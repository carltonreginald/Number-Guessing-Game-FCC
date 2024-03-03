#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n---Number Guessing Game---\n"

#get username
echo "Enter your username:"
read USERNAME

USERNAME_INPUT=$($PSQL "SELECT username from users WHERE username = '$USERNAME'")

#checks for new username
if [[ -z $USERNAME_INPUT ]]
then 
  ADD_USERNAME=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"

  #check for old username
else
  OLD_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(total_num_guesses) FROM games WHERE user_id=$USER_ID")

echo -e "\nWelcome back, $(echo $OLD_USERNAME| sed 's/  //g')! You have played $(echo $GAMES_PLAYED | sed 's/  //g') games, and your best game took $(echo $BEST_GAME | sed 's/  //g') guesses."
fi

#Guess the secret number
echo -e "\nGuess the secret number between 1 and 1000:"

#Secret number generator
SECRET_NUMBER=$[$RANDOM % 1000 + 1]
tries=0

while read USER_GUESS
do
  ((tries++))
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
      echo -e "That is not an integer, guess again:";
    continue
  fi

  if [[ $SECRET_NUMBER -lt $USER_GUESS ]]; then
    echo -e "It's lower than that, guess again:"
    continue
  fi

  if [[ $SECRET_NUMBER -gt $USER_GUESS ]]; then
    echo -e "It's higher than that, guess again:";
    continue
  fi

  if [[ $USER_GUESS -eq $SECRET_NUMBER ]]; then
    break
  fi
done

#Guessed the correct number
echo You guessed it in $tries tries. The secret number was $SECRET_NUMBER. Nice job!

#input current user game results into games table 
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INPUT_GAME_RESULTS=$($PSQL "INSERT INTO games(user_id, total_num_guesses) VALUES($USER_ID, $tries)")
