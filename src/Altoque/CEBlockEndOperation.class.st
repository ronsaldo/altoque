Class {
	#name : #CEBlockEndOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'begin',
		'successors',
		'isBackwardsBranch'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #initialization }
CEBlockEndOperation >> beBackwardsBranch [
	isBackwardsBranch := true
]

{ #category : #accessing }
CEBlockEndOperation >> begin [
	^ begin
]

{ #category : #accessing }
CEBlockEndOperation >> begin: anObject [
	begin := anObject
]

{ #category : #accessing }
CEBlockEndOperation >> end [
	
	^ self
]

{ #category : #testing }
CEBlockEndOperation >> hasSuccessors [
	
	^ successors notNil
]

{ #category : #initialization }
CEBlockEndOperation >> initialize [

	super initialize.
	successors := OrderedCollection new.
	isBackwardsBranch := false
]

{ #category : #initialization }
CEBlockEndOperation >> isBackwardsBranch [
	
	^ isBackwardsBranch
]

{ #category : #testing }
CEBlockEndOperation >> isBlockEnd [

	^ true
]

{ #category : #replacing }
CEBlockEndOperation >> replaceSuccessor: aCEBlock by: aCEBlock2 [ 
	
	self subclassResponsibility
]

{ #category : #accessing }
CEBlockEndOperation >> successor [

	"Only if one successor"
	self assert: self successors size = 1.
	^ self successors anyOne
]

{ #category : #accessing }
CEBlockEndOperation >> successors [
	^ successors
]

{ #category : #accessing }
CEBlockEndOperation >> successors: anObject [
	successors := anObject
]
