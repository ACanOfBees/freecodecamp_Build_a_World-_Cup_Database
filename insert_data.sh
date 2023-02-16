#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Program to insert data from worldcup database

DATA_FILE=games.csv
DBNAME=worldcup

echo -e "\n"~~~ inserting data from $DATA_FILE into database $DBNAME~~~"\n"

#fetch table names in alphabetical order
TABLE_NAMES_STRING=$($PSQL "select table_name from information_schema.tables where table_schema='public' and table_type='BASE TABLE' order by table_name");
TABLE_NAMES=($TABLE_NAMES_STRING)
#echo $TABLE_NAMES_STRING;

#empty database
echo $($PSQL "TRUNCATE ${TABLE_NAMES[0]}, ${TABLE_NAMES[1]}");

#fetch array of titles from first line of input file
IFS=',' read -a TITLES -e < games.csv
#get file input
#loop through lines
cat $DATA_FILE | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #if line is not title
  if [[ $YEAR != ${TITLES[0]} ]]
  then 
    #fetch teams table id of winner
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'");
    #if id not found insert team
    if [[ -z $TEAM_ID_W ]]
    then 
      SUCCESS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')");
      if [[ $SUCCESS == "INSERT 0 1" ]]
      then
        echo $SUCCESS;
        #fetch team_id
        TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'");
      fi
    fi
    #fetch teams table id of opponent
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'");
    #if id not found insert team
    if [[ -z $TEAM_ID_O ]]
    then 
      SUCCESS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')");
      if [[ $SUCCESS == "INSERT 0 1" ]]
      then
        echo $SUCCESS;
        #fetch team_id
        TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'");
      fi
    fi
    #fetch game id
    #Build where condition
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR and round='$ROUND' and winner_id=$TEAM_ID_W and opponent_id=$TEAM_ID_O and winner_goals=$WINNER_GOALS and opponent_goals=$OPPONENT_GOALS");
    #if id through name not found insert game
    if [[ -z $GAME_ID ]]
    then 
      SUCCESS=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPONENT_GOALS)");
      echo $SUCCESS
    fi
  fi
done
