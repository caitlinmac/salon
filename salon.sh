#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon ~~~~~\n"

#Display services offered
SERVICE_MENU() {
echo -e "\nServices Offered:\n"

#Get service info from services table
SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")

echo $SERVICES | sed 's/ |/)/g' 
echo -e "\nPlease select one of our services above"
}

MAKE_APPOINTMENT() {

#Their input to select a service = input service id
read SERVICE_ID_SELECTED

SERVICE_ID_CHECK=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
#if service doesn't exist, return to list of services
if [[ -z $SERVICE_ID_CHECK ]]
then
SERVICE_MENU That service does not exist
else 
echo -e "\nThank you for selecting $SERVICE_ID_CHECK"
fi

#Prompt for user phone number
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

#check if user exists in database
CUSTOMER_PHONE_CHECK=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
#if user does not exist, prompt for name
if [[ -z $CUSTOMER_PHONE_CHECK ]]
then
echo I see it is your first time booking with us, what is your name?
read CUSTOMER_NAME
#CREATE NEW CUSTOMER IN DATABASE
INSERT_NEW_CUSTOMER_INFO=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

else
echo Welcome back, $CUSTOMER_PHONE_CHECK!
fi

#prompt customer for appointment time
echo -e "\nWhat time are you available for an appointment for a $SERVICE_ID_CHECK?"
read SERVICE_TIME
echo -e "\n$SERVICE_TIME sounds good!\n"

#enter appointment information info appointments table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
echo $CUSTOMER_ID
INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments (service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED, 
$CUSTOMER_ID, '$SERVICE_TIME');")

if [[ $INSERT_NEW_APPOINTMENT='INSERT 0 1' ]]
then
CUSTOMERS_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
echo I have put you down for a $SERVICE_ID_CHECK at $SERVICE_TIME, $CUSTOMERS_NAME.
else
SERVICE_MENU "Hmm that didn't work - let's try again"
fi
}

SERVICE_MENU
MAKE_APPOINTMENT
