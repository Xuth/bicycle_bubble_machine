void setup() {
    Serial.begin(38400);
}

#define STX 2
#define ETX 3

void loop() {
    Serial.write(STX);
    Serial.write(analogRead(A0) / 16 + 32);
    Serial.write(analogRead(A1) / 16 + 32);
    Serial.write(analogRead(A2) / 16 + 32);
    Serial.write(analogRead(A3) / 16 + 32);
    Serial.write(ETX);
    delay(100);
}
    
