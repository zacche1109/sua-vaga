#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ===== Wi-Fi =====
#define WIFI_SSID     "YOUR_SSID"
#define WIFI_PASSWORD "YOUR_PASSWORD"

// ===== Firebase =====
#define API_KEY "AIzaSyCrf9T1DPBQpXv16LCn1pz63z7M_NXH1-Y"       
#define PROJECT_ID "sua-vaga-8e99e"
String parkingLotId = "3";
String spotId1 = "A1";
String spotId2 = "A2";

#define SENSOR_PIN1 4
#define SENSOR_PIN2 18

#define LED1_R 22
#define LED1_G 23

#define LED2_R 19
#define LED2_G 21

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

//começa como livre
bool lastFree1 = true;
bool lastFree2 = true;

void updateLed(bool free, int pinR, int pinG) {
  if (free) {
    // Livre = Verde
    digitalWrite(pinR, LOW);
    digitalWrite(pinG, HIGH);
  } else {
    // Ocupado = Vermelho
    digitalWrite(pinR, HIGH);
    digitalWrite(pinG, LOW);
  }
}


void updateSpotStatus(String &spotId, bool free) {
  // Cria o payload no formato exato que o Firestore espera usando concat
  String payload = "{";
  payload.concat("\"fields\": {");
  payload.concat("\"layout\": {");
  payload.concat("\"mapValue\": {");
  payload.concat("\"fields\": {");
  payload.concat("\"spots\": {");
  payload.concat("\"mapValue\": {");
  payload.concat("\"fields\": {");
  payload.concat("\"");
  payload.concat(spotId);
  payload.concat("\": {");
  payload.concat("\"mapValue\": {");
  payload.concat("\"fields\": {");
  payload.concat("\"status\": {");
  payload.concat("\"booleanValue\": ");
  payload.concat(free ? "true" : "false");
  payload.concat("}");
  payload.concat("}"); // fields do spot
  payload.concat("}"); // mapValue do spot
  payload.concat("}"); // spot
  payload.concat("}"); // fields do spots
  payload.concat("}"); // mapValue do spots
  payload.concat("}"); // spots
  payload.concat("}"); // fields do layout
  payload.concat("}"); // mapValue do layout
  payload.concat("}"); // layout
  payload.concat("}"); // fields
  payload.concat("}"); // final


  Serial.println("Payload enviado:");
  Serial.println(payload);

  String docPath = "parkingLots/";
  docPath.concat(parkingLotId);

  String mask = "layout.spots.";
  mask.concat(spotId);
  mask.concat(".status");

  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", docPath.c_str(), payload.c_str(), mask.c_str())) {
    Serial.printf("Firestore OK: %s -> %s\n", spotId.c_str(), free ? "LIVRE(true)" : "OCUPADA(false)");
  } else {
    Serial.printf("Erro Firestore (%s): %s\n", spotId.c_str(), fbdo.errorReason().c_str());
    Serial.printf("Resposta completa: %s\n", fbdo.payload().c_str());
  }
}






void setup() {
  Serial.begin(115200);

  pinMode(SENSOR_PIN1, INPUT);
  pinMode(SENSOR_PIN2, INPUT);

  pinMode(LED1_R, OUTPUT);
  pinMode(LED1_G, OUTPUT);
  pinMode(LED2_R, OUTPUT);
  pinMode(LED2_G, OUTPUT);

  Serial.printf("Conectando ao Wi-Fi: %s\n", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi conectado!");

  config.api_key = API_KEY;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Login anônimo OK");
  } else {
    Serial.printf("Falha no signup: %s\n", config.signer.signupError.message.c_str());
  }
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Força primeira escrita
  //low = detectando eltromagnetismo, ou seja, ocupado, com carro
  bool occupied1 = (digitalRead(SENSOR_PIN1) == LOW); //se está low, ou seja ocupado, occupied vai ser true
  bool occupied2 = (digitalRead(SENSOR_PIN2) == LOW);
  lastFree1 = !occupied1;
  lastFree2 = !occupied2;
  updateSpotStatus(spotId1, lastFree1);
  updateSpotStatus(spotId2, lastFree2);

  updateLed(lastFree1, LED1_R, LED1_G);
  updateLed(lastFree2, LED2_R, LED2_G);
}

void loop() {
  bool occupied1 = (digitalRead(SENSOR_PIN1) == LOW);
  bool occupied2 = (digitalRead(SENSOR_PIN2) == LOW);

  bool free1 = !occupied1;  
  bool free2 = !occupied2;

  Serial.printf("S1: %s | S2: %s\n", free1 ? "free(true)" : "OCUPADA(false)",
                                     free2 ? "free(true)" : "OCUPADA(false)");

  if (free1 != lastFree1) {
    lastFree1 = free1;
    updateSpotStatus(spotId1, free1);
    updateLed(free1, LED1_R, LED1_G); 
  }
  if (free2 != lastFree2) {
    lastFree2 = free2;
    updateSpotStatus(spotId2, free2);
    updateLed(free2, LED2_R, LED2_G); 
  }

  delay(1000);
}
