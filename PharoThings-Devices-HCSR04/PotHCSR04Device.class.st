"
I'm a class to control the ultrasonic HCSR-04 sensors.
You can use many ultrasonic sensors at the same time. Just change the PINs id. 

To use:
(inspector)
ultrasonic := board installDevice: PotHCSR04Device new.

(playground. change the board model  to your board)
ultrasonic := (RpiBoard3B current) installDevice: PotHCSR04Device new.

You can name the object using
name: 'Left sensor'

To read the distance use one of the method below. 

readDistance. ""It will return a number""
printDistance. ""It will return a string""

I'm using the GPIO0 to triggerPin and GPIO21 to echoPin as default configuration.
If you want to choose your own PIN position, you can set using the PIN Id (BCM number):

triggerPin: 27 echoPin: 17.

Some of my sensors brothers uses only 1 GPIO to send and read the ultrasonic pulse. 
You can set it using the method:

signalPin: 22.

Sometimes I can freeze. You can reboot me using

rebootSensor.
"
Class {
	#name : #PotHCSR04Device,
	#superclass : #PotDevice,
	#instVars : [
		'triggerPin',
		'echoPin',
		'triggerPinNumber',
		'echoPinNumber'
	],
	#category : #'PharoThings-Devices-HCSR04'
}

{ #category : #initialization }
PotHCSR04Device >> configureForRpiBoard3B: aBoard [
	"trigger pin send the ultrasonic pulse. 
	echoPin become on (after receive the return pulse) by the same time spent to pulse go and back
	If the trigger pin is not setted, it use the default pins GPIO0 and GPIO21 "
	
	triggerPin ifNil: [triggerPinNumber := 5. echoPinNumber := 17].
	triggerPin := aBoard pinWithId: triggerPinNumber.	
	
	"If the echo pin is false, it use the trigger pin as echo pin. Some ultrasonic sensor uses only 1 gpio to both"
	echoPinNumber ifNil: [echoPin := triggerPin] ifNotNil: [echoPin := aBoard pinWithId: echoPinNumber]
]

{ #category : #initialization }
PotHCSR04Device >> connect [
	self isConfigured ifFalse: [ board configureComplexDevice: self ]
]

{ #category : #initialization }
PotHCSR04Device >> isConfigured [ 
	^ triggerPin notNil
]

{ #category : #initialization }
PotHCSR04Device >> isConnected [
	^ board notNil
]

{ #category : #commands }
PotHCSR04Device >> printDistance [
	^ self readDistance printShowingDecimalPlaces: 1
]

{ #category : #commands }
PotHCSR04Device >> readDistance [
	self sendPulse.
	^ (self readPinStateDuration * 34300 / 2 / 1000000) asFloat round: 1
]

{ #category : #controlling }
PotHCSR04Device >> readPinStateDuration [
	| pulseStart pulseEnd |
	echoPin beDigitalInput; enablePullDownResister.
	[ echoPin value == 0 ] whileTrue: [ pulseStart := Time primUTCMicrosecondsClock ].
	[ echoPin value == 1 ] whileTrue: [ pulseEnd := Time primUTCMicrosecondsClock ].
	^ pulseEnd - pulseStart
]

{ #category : #commands }
PotHCSR04Device >> rebootSensor [
	"reset the pins when the sensor freeze"
	echoPin beDigitalOutput; value: 1.
	1 milliSeconds wait.
	echoPin value: 0; beDigitalInput; enablePullDownResister.
	triggerPin beDigitalOutput; value: 0
]

{ #category : #controlling }
PotHCSR04Device >> sendPulse [
	triggerPin beDigitalOutput. 
	triggerPin value: 0; value: 1.
	1 milliSeconds wait.
	triggerPin value: 0
]

{ #category : #settings }
PotHCSR04Device >> signalPin: aSignalPinNumber [
	self triggerPin: aSignalPinNumber echoPin: nil
]

{ #category : #settings }
PotHCSR04Device >> triggerPin: aTriggerPinNumber echoPin: aEchoPinNumber [
	
	triggerPinNumber := aTriggerPinNumber.
	echoPinNumber := aEchoPinNumber.
	
	board configureComplexDevice: self
]
