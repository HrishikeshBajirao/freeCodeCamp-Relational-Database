#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=players -t --no-align -c"

GAME(){
  SECRET=$(($RANDOM % 1000 + 1))
  echo Guess the secret number between 1 and 1000:
  read INPUT
  until [[ $INPUT =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read INPUT
  done
  GUESSES=1
  until [[ $INPUT -eq $SECRET ]]
  do
    if (( $INPUT < $SECRET ))
    then
      echo "It's higher than that, guess again:"
      (( GUESSES++ ))
      read INPUT
    else
      echo "It's lower than that, guess again:"
      (( GUESSES++ ))
      read INPUT
    fi
    if [[ ! $INPUT =~ ^[0-9]+$ ]]
    then
      until [[ $INPUT =~ ^[0-9]+$ ]]
      do
        echo That is not an integer, guess again:
        read INPUT
      done
    fi
  done
}

MAIN(){
  echo Enter your username:
  read USERNAME
  # search for username in database 
  USERNAME_SEARCH_RESULT=$($PSQL "select username from players where username='$USERNAME'")
  # if not found
  if [[ -z $USERNAME_SEARCH_RESULT ]]
  then
    # welcome info
    echo Welcome, $USERNAME! It looks like this is your first time here.
    # play the game
    GAME
    echo You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!
    # insert username into database
    INSERT_PLAYER_RESULT=$($PSQL "insert into players(username, games_played, best_game) values('$USERNAME', 1, $GUESSES)")
  else
    # welcome info
    GAMES_PLAYED=$($PSQL "select games_played from players where username='$USERNAME'")
    BEST_GAME=$($PSQL "select best_game from players where username='$USERNAME'")
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
    # play the game
    GAME
    echo You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!
    # update the database
    UPDATE_GAMES_PLAYED=$($PSQL "update players set games_played=$((($GAMES_PLAYED+1))) where username='$USERNAME'")
    if (( $GUESSES < $BEST_GAME ))
    then
      UPDATE_BEST_GAME=$($PSQL "update players set best_game=$GUESSES where username='$USERNAME'")
    fi
  fi
}
MAIN