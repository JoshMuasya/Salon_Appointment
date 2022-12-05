#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ Hello in Salon Appointment Scheduler ~~\n"

MAIN_MENU () {
  CUSTOMER_CHOICE
  CUSTOMER_INFO
  SELECT_TIME
}

CUSTOMER_CHOICE () {
  # Get services offered
  SERVICE_OFFERED=$($PSQL "SELECT service_id, name FROM services") 
  echo -e "\nHere are the services we have available:"
  echo "$SERVICE_OFFERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nPick number of service what do you want?"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED == [1-5] ]]
  then
    echo "That is not a valid service number."
    CUSTOMER_CHOICE
  else
    SERVICE_NAME_TO_SELECT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
  fi
}

CUSTOMER_INFO () {
  # Get Phone number from Customer
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE 

  # If phone number is empty
  if [[ -z $CUSTOMER_PHONE ]]
  then
    echo "Please input valid phone number"
    CUSTOMER_INFO 
  else
    # Check if phone number is in DB
    CHECKED_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'") 
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name IS NULL")

    # If phone number not in DB
    if [[ -z $CHECKED_PHONE ]] 

    # Insert into DB
    then 
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "Name can't be empty"
        CUSTOMER_INFO 
      else
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    else 
      if [[ ! -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME=$($PSQL "UPDATE customers SET name='$CUSTOMER_NAME' WHERE phone='$CUSTOMER_PHONE'")
      fi
    fi
  fi
}

SELECT_TIME () {
  echo -e "\nPlease input time what you want to get service (hh:mm)"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    echo "Please input valid time hh:mm"
    SELECT_TIME 
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE_NAME_TO_SELECT at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

EXIT () {
  echo -e "\nThank you for your choice"
}

MAIN_MENU