#!/bin/bash

readonly PORT=80
readonly AUTH_TOKEN=Oushee2gophoLoocheip5OfeiC4mahW4Aajaiy
readonly DB_USER=loghook
readonly DB_PASSWORD=QJum58NxH1gLNfrftljQY0LM4oXnEgac-L
readonly DB_DATABASE=loghook
readonly CRLF=$'\r\n'
readonly SERVER_NAME=pingpong

trap 'echo shutdown.; exit' INT

rm -f response
mkfifo response

function handleRequest() 
{
   while read l
   do
      echo $l

      line=$(echo $l | tr -d '[\r\n]')

      [ -z "$line" ] && break

      REGEX_REQUEST_METHOD='(.*?)\s(.*?)\sHTTP.*?'
      [[ "$line" =~ $REGEX_REQUEST_METHOD ]] && REQUEST_METHOD=$(echo $line | sed -E "s/$REGEX_REQUEST_METHOD/\1 \2/")c

      REGEX_CONTENT_LENGTH='Content-Length:\s(.*?)'
      [[ "$line" =~ $REGEX_CONTENT_LENGTH ]] && CONTENT_LENGTH=$(echo $line | sed -E "s/$REGEX_CONTENT_LENGTH/\1/")

      REGEX_AUTHENTICATE='Authenticate:\s(.*?)'
      [[ "$line" =~ $REGEX_AUTHENTICATE ]] && AUTHENTICATE=$(echo $line | sed -E "s/$REGEX_AUTHENTICATE/\1/")
   done

   if [ "$AUTHENTICATE" == "$AUTH_TOKEN" ]
   then
      if [ ! -z "$CONTENT_LENGTH" ]
      then

         BODY_REGEX='([a-zA-Z0-9]+)=(.*?)'
         BODY=

         while read -n$CONTENT_LENGTH -t1 line
         do
            echo $line
            line=`echo $line | tr -d '[\r\n]'`

            BODY = "$BODY"

            [ -z "$line" ] && break

            read INPUT_NAME INPUT_VALUE <<< $(echo $line | sed -E "s/$BODY_REGEX/\1 \2/")
            
            declare -A param   
            while IFS='=' read -r -d '&' key value; do
               param["$key"]=$value
            done <<<"${QUERY_STRING:+"${QUERY_STRING}&"}"

            
         done
      fi
   fi

   
}

echo "listen $PORT"

while true
do
      cat response | nc -lN $PORT | handleRequest
done
