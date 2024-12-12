#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  # check if the argument is atomic number 
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where atomic_number=$1")
  # or if argument is a symbol
  elif [[ $(echo $1 | wc -m) -le 3 ]]
  then
    # get atomic number
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where symbol ilike '$1'")
  # or argument is the name of the element
  else
    # get atomic number
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where name ilike '$1'")
  fi

  #if element not found output not found
  if [[ -z $ATOMIC_NUMBER ]]
  then
  echo I could not find that element in the database.
  else
    # get elements info
    NAME=$($PSQL "select name from elements where atomic_number=$ATOMIC_NUMBER")
    SYMBOL=$($PSQL "select symbol from elements where atomic_number=$ATOMIC_NUMBER")
    TYPE=$($PSQL "select type from elements full join properties using (atomic_number) left join types using (type_id) where atomic_number=$ATOMIC_NUMBER")
    MASS=$($PSQL "select atomic_mass from elements full join properties using (atomic_number) where atomic_number=$ATOMIC_NUMBER")
    BOILING=$($PSQL "select boiling_point_celsius from elements full join properties using (atomic_number) where atomic_number=$ATOMIC_NUMBER")
    MELTING=$($PSQL "select melting_point_celsius from elements full join properties using (atomic_number) where atomic_number=$ATOMIC_NUMBER")

    echo  "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
fi