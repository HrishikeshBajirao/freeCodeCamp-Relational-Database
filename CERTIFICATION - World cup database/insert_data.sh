#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate games, teams")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_G OPPONENT_G
do
  #if condition to omit the first line
  if [[ $YEAR != year ]]
  then
    # get winnner team id
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'");
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_WINNER_TEAM=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER_TEAM == 'INSERT 0 1' ]]
      then 
        echo Inserted in Teams, $WINNER
      fi
    fi
    # get new winner team id
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'");

    # get opponent team id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'");
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_OPPONENT_TEAM=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM == 'INSERT 0 1' ]]
      then 
        echo Inserted in Teams, $OPPONENT
      fi
    fi
    # get new opponent team id
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'");

    # insert game
    INSERT_GAME=$($PSQL "insert into games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) values('$YEAR', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_G', '$OPPONENT_G', '$ROUND')")
    if [[ $INSERT_GAME = 'INSERT 0 1' ]]
    then
      echo Inserted in Games
    fi
  fi
done