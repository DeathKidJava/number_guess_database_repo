#!/bin/bash

# declare PSQL for one-line-queries
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1001 ))

# print game caption
echo -e "\n~~~ Number Guess ~~~"

# read user's name
echo -e "\nEnter your username:\n"
read USER_NAME

# get user from query
USER_INFO="$($PSQL "SELECT * FROM users WHERE username='$USER_NAME';")"
# if user_id empty
if [[ $USER_INFO ]]
then
  # print wb-message
    # format message
    echo $USER_INFO | while IFS="|" read USER_NAME GAMES_PLAYED BEST_GAME
    do
      echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
    done
else
  # print welcome-new-user-message
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  # insert new user into db
  INSERT_USER_RESULT="$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME');")"
fi

# TEST ECHO
echo $SECRET_NUMBER

# declare
NUMBER_OF_GUESSES=0
IS_GAME_OVER=false

# print guess-the-number
echo -e "\nGuess the secret number between 1 and 1000:\n"

while [[ $IS_GAME_OVER != true ]]
do
  # read users guess
  read USER_GUESS

  # is the user input an integer?
  IS_USER_GUESS_NUMBER=$(echo $USER_GUESS | grep -E '^[0-9]+$')
  #if USER_GUESS not an INT
  if [[ -z $IS_USER_GUESS_NUMBER ]]
  then
    # print that its not an int
    echo -e "\nThat is not an integer, guess again:\n"
  fi

  # if USER_GUESS < SECRET_NUMBER
  if [[ $USER_GUESS < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    # increment number of guesses
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES+1 ))
    # read USER_GUESS
  # else if USER_GUESS > RANDOM_NUMBER
  elif [[ $USER_GUESS > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    #increment number of guesses
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES+1 ))
    # read USER_GUESS
  # else
  else
    #increment number of guesses
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES+1 ))
    IS_GAME_OVER=true
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # update db
      # increment games_played
      UPDATE_GAMES_PLAYED_RESULT="$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USER_NAME';")"
      # if number of guesses < best_game
      if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]] || [[ -z $BEST_GAME ]]
      then
        # update best game
        UPDATE_BEST_GAME_RESULT="$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USER_NAME';")"
      fi
  fi

done
#wrong comment for commit