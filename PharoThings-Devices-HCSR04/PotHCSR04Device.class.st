Class {
	#name : #PotHCSR04Device,
	#superclass : #PotDevice,
	#instVars : [
		'pulseStart',
		'pulseEnd',
		'pulseDuration',
		'triggerPin',
		'echoPin'
	],
	#category : #'PharoThings-Devices-HCSR04'
}

{ #category : #initialization }
PotHCSR04Device >> configureForRpiBoard3B: aBoard [
	triggerPin := aBoard pinWithId: 21.	"trigger pin send the ultrasonic pulse"
	echoPin := aBoard pinWithId: 0	"echo pin become on (after read the return pulse) by the same time spent to pulse go and back"
]

{ #category : #initialization }
PotHCSR04Device >> connect [
	self isConfigured ifFalse: [ board configureComplexDevice: self ].
	self rebootPinsState
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

{ #category : #controlling }
PotHCSR04Device >> readDistance [
	^ (self readDurationPinEnable * 34300 / 2 / 1000000) asFloat round: 1
]

{ #category : #controlling }
PotHCSR04Device >> readDurationPinEnable [
	[ echoPin value == 0 ] whileTrue: [ pulseStart := Time primUTCMicrosecondsClock ].
	[ echoPin value == 1 ] whileTrue: [ pulseEnd := Time primUTCMicrosecondsClock ].
	^ pulseEnd - pulseStart
]

{ #category : #controlling }
PotHCSR04Device >> rebootPinsState [
	"reset the pins when the sensor freeze"
	echoPin beDigitalOutput; value: 1.
	1 milliSeconds wait.
	echoPin value: 0; beDigitalInput; enablePullDownResister.
	triggerPin beDigitalOutput; value: 0
]

{ #category : #controlling }
PotHCSR04Device >> sendPulse [
	triggerPin value: 1.
	1 milliSeconds wait.
	triggerPin value: 0
]
