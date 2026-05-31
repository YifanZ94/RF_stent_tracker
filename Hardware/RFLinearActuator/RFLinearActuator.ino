/****************************************************************************** 
Andrew Plesniak
9/19/2018

This program controls a stepper motor using a sparkfun easydriver.
1/8 micro stepping

From Datasheet: 26.667 Steps/mm = 677.3418 Steps/in, but I am having to divide this by 2 in order to get the correct distances, not sure why yet.
******************************************************************************/
//Declare pin functions
#define stp 3
#define dir 2
#define MS1 4
#define MS2 5
#define EN  6
#define PeakDetector A0

//Declare variables for functions
float user_input_inches, read1,read2,read3,read4,read5, avgread;
int steps;
int x;
int y;
int state;
char command;
char movecommand = 'M';
char datacollectcommand = 'C';
char acknowledge = 'A';
char done = 'D';

void setup() {
  pinMode(stp, OUTPUT);
  pinMode(dir, OUTPUT);
  pinMode(MS1, OUTPUT);
  pinMode(MS2, OUTPUT);
  pinMode(EN, OUTPUT);
  resetEDPins(); //Set step, direction, microstep and enable pins to default states
  Serial.begin(9600); //Open Serial connection for debugging
}

//Main loop
void loop() {
  while(Serial.available()){
      command = Serial.read();  //read command from Matlab
      
      if (command == movecommand){ //move command
        Serial.println(acknowledge); //using as an acknowlege handshake      
        while (Serial.available() == false); //wait until data is ready 
        user_input_inches = Serial.parseFloat(); //Read user input and trigger appropriate function
        digitalWrite(EN, LOW); //Pull enable pin low to allow motor control
        steps = InchesToSteps(user_input_inches);
        if (steps > 0){
          StepForward(steps);
          }
        else if (steps < 0){
          StepBackward(steps); 
          }
        resetEDPins();
        Serial.println(done); //using as a done command
        }
        else if (command == datacollectcommand) { //collect data command

          Serial.println(acknowledge); //using as an acknolege handshake
          read1= analogRead(PeakDetector)*(5.0 / 1023.0);
          read2= analogRead(PeakDetector)*(5.0 / 1023.0);
          read3= analogRead(PeakDetector)*(5.0 / 1023.0);
          read4= analogRead(PeakDetector)*(5.0 / 1023.0);
          read5= analogRead(PeakDetector)*(5.0 / 1023.0);
          avgread = (read1+read2+read3+read4+read5)/5;
          Serial.write((uint8_t*)&avgread, sizeof(avgread));
          Serial.println(done);
          }
  }
}

//Reset Easy Driver pins to default states
void resetEDPins()
{
  digitalWrite(stp, LOW);
  digitalWrite(dir, LOW);
  digitalWrite(MS1, LOW);
  digitalWrite(MS2, HIGH);
  digitalWrite(EN, HIGH);
}


// 1/8th microstep foward mode function
void StepForward(int steps)
{
  steps = abs(steps);
  digitalWrite(dir, LOW); //Pull direction pin low to move "forward"
  digitalWrite(MS1, HIGH); //Pull MS1, and MS2 high to set logic to 1/8th microstep resolution
  digitalWrite(MS2, HIGH);
  for(x= 1; x <= steps; x++)  //Loop the forward stepping
  {
    digitalWrite(stp,HIGH); //Trigger one step forward
    delay(1);
    digitalWrite(stp,LOW); //Pull step pin low so it can be triggered again
    delay(1);
  }
  steps = 0;
}


// 1/8th microstep backward mode function
void StepBackward(int steps)
{
  steps = abs(steps);
  digitalWrite(dir, HIGH); //Pull direction pin HIGH move "backward"
  digitalWrite(MS1, HIGH); //Pull MS1, and MS2 high to set logic to 1/8th microstep resolution
  digitalWrite(MS2, HIGH);
  for(x= 1; x <= steps; x++)  //Loop the back stepping
  {
    digitalWrite(stp,HIGH); //Trigger one step backward
    delay(1);
    digitalWrite(stp,LOW); //Pull step pin low so it can be triggered again
    delay(1);
  }
  steps = 0;
}

int InchesToSteps(float inches){
  int steps = 0;
  steps = round(inches * 266.67/2);  
  return(steps);
  }
