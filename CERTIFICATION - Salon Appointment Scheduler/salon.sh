#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~~~ Vilenou Salon ~~~~~\n"

HOME_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Welcome to Vilenou, How can i help you?\n1) cut\n2) color\n3) perm\n4) style\n5) trim\n"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT $SERVICE_ID_SELECTED ;;
    2) APPOINTMENT $SERVICE_ID_SELECTED ;;
    3) APPOINTMENT $SERVICE_ID_SELECTED ;;
    4) APPOINTMENT $SERVICE_ID_SELECTED ;;
    5) APPOINTMENT $SERVICE_ID_SELECTED ;;
    *) HOME_MENU "Please enter a valid option of service." ;;
  esac
}
APPOINTMENT(){
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME_RESULT=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME_RESULT | sed -n 's/.*------ \([a-zA-Z0-9_]*\) .*/\1/p')
  # ask for phone number and get customer id
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME_RESULT=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME_RESULT | sed -n 's/.*------ \([a-zA-Z0-9_]*\) .*/\1/p')
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for name
    echo -e "\nI didn't find your phone number in records. What's your name?"
    read CUSTOMER_NAME
    # add the customer to database
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer_id
  CUSTOMER_ID_RESULT=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$(echo $CUSTOMER_ID_RESULT | sed -n 's/.*------ \([a-zA-Z0-9_]*\) .*/\1/p')
  # get apponintment time from customer
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME"
  read SERVICE_TIME
  #insert and print appointment info
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" )
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

HOME_MENU