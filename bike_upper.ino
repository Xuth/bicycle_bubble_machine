#include <limits.h>

#define ARM1_STEP 10
#define ARM1_DIR 11
#define ARM2_STEP 8
#define ARM2_DIR 9
#define PUMP 2
#define STEP_ENABLE 12

#define MAX_ARM (200UL * 8)  // 1 rotation * 200 steps per rotation * 8 uSteps per step

#define SLEEP_TIME (60UL * 1000UL * 1000UL)

void setup() {
    pinMode(ARM1_STEP, OUTPUT);
    pinMode(ARM1_DIR, OUTPUT);
    pinMode(ARM2_STEP, OUTPUT);
    pinMode(ARM2_DIR, OUTPUT);
    pinMode(STEP_ENABLE, OUTPUT);

    digitalWrite(ARM1_STEP, LOW);
    digitalWrite(ARM1_DIR, LOW);
    digitalWrite(ARM2_STEP, LOW);
    digitalWrite(ARM2_DIR, LOW);
    digitalWrite(STEP_ENABLE, LOW);
    
    Serial.begin(38400);
}


void enableStep() {
    digitalWrite(STEP_ENABLE, LOW);
}

void disableStep() {
    digitalWrite(STEP_ENABLE, HIGH);
}

class Pump {
    int pin;
    int state;  // 0: off, 1: pwm on, 2: pwm off
    unsigned long duty;   // how many us to be on every cycleTime
    unsigned long stateChange;  // micros() reading from last time state == 1

    const unsigned long cycleTime = 5000;  // originally this was 5 ms but this works better for the motor at 100 ms
    
    void pumpOn() {
	digitalWrite(pin, HIGH);
    }

    void pumpOff() {
	digitalWrite(pin, LOW);
    }

    
public:
    void setDuty(float dutyPercent) {
	duty = (unsigned long)(float(cycleTime) * dutyPercent / 100);
    }

    Pump(int pumpPin, float dutyPercent) {
	state = 0;
	setDuty(dutyPercent);
	pin = pumpPin;
	pinMode(pin, OUTPUT);
	pumpOff();
    }

    void doPWM() {
	if (state == 0) {
	    pumpOff();
	    return;
	}
	
	unsigned long diff = micros() - stateChange;
	if (state == 1) {
	    if (diff < duty)
		return;
	    pumpOff();
	    state = 2;
	} else {
	    if (diff < cycleTime)
		return;
	    pumpOn();
	    state = 1;
	    stateChange = micros();
	}
    }

    void on() {
	state = 1;
	stateChange = micros();
	pumpOn();
    }

    void off() {
	state = 0;
	pumpOff();
    }
};


class Stepper {
private:
    int stepPin;
    int dirPin;
    int stepPin2;
    int dirPin2;
    int dir2Inv;
    
    char enable1;
    char enable2;
    char state = 0;  // 0 nothing, 1 accel, 2 cv, 3 decel
    char direction;  // integer version of direction

    long position;  // current position
    long cvPos;  // start constant velocity at this position for normal move
    long decelPos;  // start deceleration at this position for normal move

    long maxPos;    // if we pass maxPos start max deceleration
    long minPos;    // if we pass minPos start max deceleration

    float velocity;  // current steps / sec
    float baseVelocity;  // steps / sec before acceleration
    float targetVelocity;  // steps / sec. our target velocity
    float accel;   // steps / sec^2
    float maxAccel;  // max accel used for fast stops

    unsigned long stateTime;  // time of last state change
    unsigned long stateSteps = 0;  // steps moved since last state change

    void resetDecelPos() {
	decelPos = LONG_MAX;
    }

    void setState(int s) {
	//Serial.print("setting state ");
	//Serial.println(s);
	state = s;
	stateTime = micros();
	stateSteps = 0;
	baseVelocity = velocity;
	if (state == 0) {
	    velocity = 0;
	    baseVelocity = 0;
	}
    }

public:
    void stop(float acceleration = -1) {
	if (acceleration == -1)
	    acceleration = maxAccel;
	else
	    acceleration = abs(acceleration);

	setState(3);
	accel = acceleration;
    }

private:
    void setDirection(int d) {
	direction = d;
	if (direction > 0) {
	    digitalWrite(dirPin, LOW);
	    if (stepPin2 >= 0)
		if (dir2Inv)
		    digitalWrite(dirPin2, HIGH);
		else
		    digitalWrite(dirPin2, LOW);
	} else {
	    digitalWrite(dirPin, HIGH);
	    if (stepPin2 >= 0)
		if (dir2Inv)
		    digitalWrite(dirPin2, LOW);
		else
		    digitalWrite(dirPin2, HIGH);
	}
    }
	    
    void step() {
	if (enable1 > 0)
	    digitalWrite(stepPin, HIGH);
	if (enable2 > 0)
	    if (stepPin2 > -1)
		digitalWrite(stepPin2, HIGH);
	delayMicroseconds(1);
	if (enable1 > 0)
	    digitalWrite(stepPin, LOW);
	if (enable2 > 0)
	    if (stepPin2 > -1)
		digitalWrite(stepPin2, LOW);

	position += direction;
	stateSteps += 1;
	
	if (position > maxPos && direction > 0) {
	    stop(maxAccel);
	} else if (position < minPos && direction < 0) {
	    stop(maxAccel);
	}
    }
    
public:
    Stepper(float maxAccel, int stepPin, int dirPin, int stepPin2=-1, int dirPin2=-1, int dir2Inv=0) :
	maxAccel(maxAccel), stepPin(stepPin), dirPin(dirPin), stepPin2(stepPin2), dirPin2(dirPin2), dir2Inv(dir2Inv) {
	setStepperPins(stepPin, dirPin);
	setSecondaryPins(stepPin2, dirPin2);
	velocity = 0;
	targetVelocity = 0;
	setDirection(1);
	setState(0);
	
	position = 0;
	maxPos = 1000000000L;
	minPos = -1000000000L;
	resetDecelPos();
    }

    void setPos(long pos) { position = pos; }
    long getPos() { return position; }

    float getVelocity() { return velocity; }
    long getDecelPos() { return decelPos; }
    
    void setMaxPos(long pos) { maxPos = pos; }
    void setMinPos(long pos) { minPos = pos; }
    void setAccel(float a) { accel = a; }


    void setStepperPins(int stepperPin, int directionPin) {
	enable1 = 1;
	stepPin = stepperPin;
	dirPin = directionPin;
	pinMode(stepPin, OUTPUT);
	pinMode(dirPin, OUTPUT);
	digitalWrite(stepPin, LOW);
    }
    void setSecondaryPins(int stepperPin, int directionPin) {
	stepPin2 = stepperPin;
	dirPin2 = directionPin;
	enable2 = 0;
	if (stepPin2 > -1) {
	    enable2 = 1;
	    pinMode(stepPin2, OUTPUT);
	    pinMode(dirPin2, OUTPUT);
	    digitalWrite(stepPin, LOW);
	}
    }

    void enable(int which) {
	if (which == 1) {
	    Serial.println("enabling 1");
	    enable1 = 1;
	}
	if (which == 2) {
	    Serial.println("enabling 2");
	    enable2 = 1;
	}
    }
    void disable(int which) {
	if (which == 1) {
	    Serial.println("disabling 1");
	    enable1 = 0;
	}
	if (which == 2) {
	    Serial.println("disabling 2");
	    enable2 = 0;
	}
    }

    int finished() {
	return (state == 0);
    }
    
    void iterate() {
	static unsigned long lastMicrosPerStep = 0;

	/*
	Serial.print(position);
	Serial.print(" ");
	Serial.print(velocity);
 	Serial.print(" ");
	Serial.print(targetVelocity);
	Serial.print(" ");
	Serial.println(accel);
	*/

	if (state == 0)
	    return;
	
	unsigned long curMicros = micros() - stateTime;
	float curTime = float(curMicros) / 1000000;
	unsigned long expectedDist;

	if (state == 1) {
	    velocity = curTime * accel;
	    expectedDist = (unsigned long)(curTime * velocity / 2);
	} else if (state == 2) {
	    velocity = targetVelocity;
	    expectedDist = (unsigned long)(velocity * curTime);
	} else if (state == 3) {
	    velocity = baseVelocity - curTime * accel;
	    expectedDist = (unsigned long)(curTime * (baseVelocity + velocity) / 2);
	}
	
	if (stateSteps < expectedDist)
	    step();

	if (state == 1 && position == cvPos)
	    setState(2);
	if (state == 2 && position == decelPos)
	    setState(3);
	if (state == 3 && velocity <= 0.0)
	    setState(0);
    }

#if 0  // Eventually I want a version of this that will work while the motor is already moving but not today
    void gotoPos(long destination, float maxVelocity, float acceleration) {
	acceleration = abs(acceleration);
	
	// first figure out where we'd reach if we set our target velocity to zero
	float seconds = abs(velocity) / acceleration;
	float distance = seconds * velocity / 2.0;
	long baseLoc = position + distance;

	accelSign = 1;
	if (destination < baseLoc)
	    accelSign = -1;
    }
#endif

    // this assumes our current velocity is 0
    void gotoPos(long destination, float maxVelocity, float acceleration) {
	Serial.print("enable:  ");
	Serial.print((int)enable1);
	Serial.print(' ');
	Serial.println((int)enable2);
	Serial.print("arm pins: ");
	Serial.print(stepPin);
	Serial.print(' ');
	Serial.print(dirPin);
	Serial.print(' ');
	Serial.print(stepPin2);
	Serial.print(' ');
	Serial.println(dirPin2);
	
	acceleration = abs(acceleration);
	maxVelocity = abs(maxVelocity);
	float distance = destination - position;
	long absDist = abs(distance);
	int distSign;
	if (position < destination) {
	    setDirection(1);
	    distSign = 1;
	} else {
	    setDirection(-1);
	    distSign = -1;
	}
	
        float accelTime = maxVelocity / acceleration;
	long accelDist = accelTime * maxVelocity / 2;
	if (accelDist * 2 >= absDist) {
	    accelDist = absDist / 2;
	    cvPos = decelPos = position + (distSign * accelDist);
	} else {
	    cvPos = position + (distSign * accelDist);
	    decelPos = destination - (distSign * accelDist);
	}
	accel = acceleration;
	targetVelocity = maxVelocity;
	setState(1);
    }
};

#define STX 2
#define ETX 3

class SerialPanel {
    unsigned char vals[4];
    unsigned char tempVals[4];
    int state;

public:
    SerialPanel() {
	state = 0;
	for (int i = 0; i < 4; ++i)
	    vals[i] = 0;
    }

    unsigned char val(int loc) {
	return vals[loc];
    }

    void iterate() {
	while(1) {
	    int b = Serial.read();
	    if (b == -1)
		return;
	    if (state == 0)
		if (b == STX) {
		    state = 1;
		    continue;
		}
	    if (state == 5) {
		if (b == ETX)
		    for (int i = 0; i < 4; ++i)
			vals[i] = tempVals[i];
		state = 0;
		continue;
	    }
	    if (b < 32 || b > 96) {
		state = 0;
		continue;
	    }
	    tempVals[state-1] = b - 32;
	    state++;
	    continue;
	}
    }

};


const float armAccel = 3000;
const float armSpeed = 3000;
Pump pump = Pump(PUMP, 70.0);
Stepper arms = Stepper(armAccel, ARM1_STEP, ARM1_DIR, ARM2_STEP, ARM2_DIR, 1);
SerialPanel panel = SerialPanel();

void iterate() {
    arms.iterate();
    pump.doPWM();
    panel.iterate();
}

void iDelay(unsigned long msec) {
    unsigned long start = millis();
    while (millis() - start < msec) {
	iterate();
    }
}

void armsTo(long pos) {
    arms.gotoPos(pos, armSpeed, armAccel);
    while(!arms.finished())
	iterate();
}

void pumpFor(unsigned long msec) {
    pump.on();
    iDelay(msec);
    pump.off();
}

void initArms() {
    enableStep();
    arms.setPos(0);
    arms.enable(1);
    arms.disable(2);
    armsTo(2400);
    delay(100);
    armsTo(2000);
    
    arms.setPos(0);
    arms.enable(2);
    arms.disable(1);
    armsTo(2400);
    delay(100);
    armsTo(2000);

    arms.enable(1);
    
    arms.setPos(0);
}

void cycle() {
    static int cycleCount = 0;
    if (++cycleCount == 100) {
	initArms();
	cycleCount = 0;
    }

    pumpFor(panel.val(0) * 100);
    iDelay(600);
    int reach = panel.val(1) * -20;
    armsTo(reach);
    //pumpFor(300);
    iDelay(panel.val(2) * 100);
    armsTo(0);
}

void loop() {
    arms.setPos(0);
    initArms();
    delay(1000);
    while(1) {
	cycle();
    }
}
