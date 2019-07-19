"
I'm a class to control the ultrasonic HCSR-04 sensors.
You can use many ultrasonic sensors at the same time. Just create a new instance with different gpios. 

How Does it Work?
The ultrasonic sensor uses sonar to determine the distance to an object. Here’s what happens:
- The transmitter (trig pin) sends a signal: a high-frequency sound.
- When the signal finds an object, it is reflected and
- the transmitter (echo pin) receives it.
The time between the transmission and reception of the signal allows us to calculate the distance to an object. This is possible because we know the sound’s velocity in the air.

To use:
- inspector
ultrasonic := board installDevice: (PotHCSR04Device triggerPin: 11 gpioHeader echoPin: 13 gpioHeader).

- playground, change the board model to your board
ultrasonic := (RpiBoard3B current) installDevice: (PotHCSR04Device triggerPin: 11 gpioHeader echoPin: 13 gpioHeader).

You can name the object using
name: 'Left sensor'.

To read the distance use one of the method below. 

readDistance. ""It will return a number"".
printDistance. ""It will return a string"".

If you want to choose your own PIN position, you can set using the PIN Id (BCM number):

triggerPin: 27 echoPin: 17.

Some of my sensors brothers uses only 1 GPIO to send and read the ultrasonic pulse. 
You can set it using the method:

ultrasonic := (RpiBoard3B current) installDevice: (PotHCSR04Device signalPin: 13 gpioHeader).

Sometimes I can freeze. You can reboot me using

rebootSensor.
"
Class {
	#name : #PotHCSR04Device,
	#superclass : #PotDevice,
	#instVars : [
		'triggerPin',
		'echoPin'
	],
	#category : #'PharoThings-Devices-HCSR04'
}

{ #category : #settings }
PotHCSR04Device class >> signalPin: aGPIOPin [
	^self new
	  triggerPin: aGPIOPin;
	  echoPin: aGPIOPin;
	  yourself
]

{ #category : #settings }
PotHCSR04Device class >> triggerPin: aGPIOPin1 echoPin: aGPIOPin2 [
	^self new
	  triggerPin: aGPIOPin1;
	  echoPin: aGPIOPin2;
	  yourself
]

{ #category : #commands }
PotHCSR04Device >> calculateDistance: aTravelTimeNumber [
	"distance = (traveltime/2) x speed of sound
	The speed of sound is: 343m/s
	We need to divide the traveltime by 2 because we have to take into account that the wave was sent, hit the object, and then returned back to the sensor."
	^ (aTravelTimeNumber * 34300 / 2 / 1000000) asFloat round: 1
]

{ #category : #initialization }
PotHCSR04Device >> connect [
	^ nil
]

{ #category : #accessing }
PotHCSR04Device >> echoPin [
	^ echoPin
]

{ #category : #accessing }
PotHCSR04Device >> echoPin: anObject [
	^ echoPin := anObject
]

{ #category : #initialization }
PotHCSR04Device >> isConfigured [ 
	^ triggerPin notNil
]

{ #category : #initialization }
PotHCSR04Device >> isConnected [
	^ board notNil
]

{ #category : #accessing }
PotHCSR04Device >> peripherals [
	^ { triggerPin. echoPin }
]

{ #category : #commands }
PotHCSR04Device >> printDistance [
	^ self readDistance printShowingDecimalPlaces: 1
]

{ #category : #commands }
PotHCSR04Device >> readDistance [
	"Send a pulse, read the travel time of pulse and return the distance in cm"
	| travelTime semaphore |
	semaphore := Semaphore new.
	[ self sendPulse.
	travelTime := self readPinStateDuration.
	semaphore signal ] fork.
	semaphore 
		wait: 100 milliSeconds
		onCompletion: [ ^ self calculateDistance: travelTime ] 
		onTimeout: [ self rebootSensor. ^ -1 ]
]

{ #category : #controlling }
PotHCSR04Device >> readPinStateDuration [
	"The echo PIN will be active for the same length of time between sending and receiving the signal. It will be activated after receiving the sound wave back."
	| pulseStart pulseEnd |
	echoPin beDigitalInput; enablePullDownResister.
	[ echoPin value == 0 ] whileTrue: [ pulseStart := Time primUTCMicrosecondsClock ].
	[ echoPin value == 1 ] whileTrue: [ pulseEnd := Time primUTCMicrosecondsClock ].
	^ pulseEnd - pulseStart
]

{ #category : #commands }
PotHCSR04Device >> rebootSensor [
	"Reset the pins when the sensor freeze"
	echoPin beDigitalOutput; value: 1.
	1 milliSeconds wait.
	echoPin value: 0; beDigitalInput; enablePullDownResister.
	triggerPin beDigitalOutput; value: 0
]

{ #category : #controlling }
PotHCSR04Device >> sendPulse [
	triggerPin beDigitalOutput; value: 0; value: 1.
	1 milliSeconds wait.
	triggerPin value: 0
]

{ #category : #accessing }
PotHCSR04Device >> triggerPin [
	^ triggerPin
]

{ #category : #accessing }
PotHCSR04Device >> triggerPin: anObject [
	triggerPin := anObject
]
