#!/bin/bash
cd /home/ahmed/Documents/obsi/Backend/
./mvnw clean package

java -jar /home/ahmed/Documents/obsi/Backend/target/welcome-demo-0.0.1-SNAPSHOT.jar
