Class {
	#name : #PotHCSR04Device,
	#superclass : #PotDevice,
	#instVars : [
		'pulseStart',
		'pulseEnd',
		'trig',
		'echo',
		'pulseDuration'
	],
	#category : #'PharoThings-Devices-HCSR04'
}

{ #category : #controlling }
PotHCSR04Device >> connect [
	trig board: board; beDigitalOutput; value: 0.
	echo board: board; beDigitalInput; enablePullDownResister.
	

]

{ #category : #initialization }
PotHCSR04Device >> initialize [
	echo := PotClockGPIOPin id: 5 number: 21.
	trig := PotClockGPIOPin id: 17 number: 0.
]

{ #category : #accessing }
PotHCSR04Device >> pulseDuration [
	self runPulse. 
	^ pulseEnd - pulseStart
]

{ #category : #accessing }
PotHCSR04Device >> readDistance [
	^ (self pulseDuration * 34300 / 2 / 1000000) asFloat printShowingDecimalPlaces: 1
]

{ #category : #accessing }
PotHCSR04Device >> readPulse [
	[ echo value == 0 ] whileTrue: [ pulseStart := Time primUTCMicrosecondsClock ].
	[ echo value == 1 ] whileTrue: [ pulseEnd := Time primUTCMicrosecondsClock ]
]

{ #category : #accessing }
PotHCSR04Device >> reboot [
	echo beDigitalOutput; value: 1.
	Delay forSeconds: 0.00003.
	echo value: 0; beDigitalInput; enablePullDownResister.
]

{ #category : #accessing }
PotHCSR04Device >> runPulse [
	self sendPulse.
	self readPulse
	
	
		
	
]

{ #category : #accessing }
PotHCSR04Device >> sendPulse [
	trig value: 1.
	Delay forSeconds: 0.00001.
	trig value: 0
]
