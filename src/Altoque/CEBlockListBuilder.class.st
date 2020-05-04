Class {
	#name : #CEBlockListBuilder,
	#superclass : #InstructionClient,
	#instVars : [
		'instructionFactory',
		'currentPC',
		'blocks',
		'bytecodeScanner',
		'nextBlockID',
		'currentBlock',
		'incoming',
		'lastInstructionFellThrough'
	],
	#category : #Altoque
}

{ #category : #building }
CEBlockListBuilder class >> buildBlocksFrom: aCollection [ 
	
	^ self new buildBlocksFrom: aCollection
]

{ #category : #'block-management' }
CEBlockListBuilder >> appendBlockAtBytecodeIndex: aBytecodeIndex [
	
	^ self appendBlockAtBytecodeIndex: aBytecodeIndex isBackwardsBranch: false
]

{ #category : #'block-management' }
CEBlockListBuilder >> appendBlockAtBytecodeIndex: aBytecodeIndex isBackwardsBranch: aBoolean [
	| block |
	blocks
		detect: [ :b | b bytecodeIndex = aBytecodeIndex ]
		ifFound: [ :b | ^ b ].
	
	block := CEBlock new
		id: instructionFactory allocateBlockID;
		bytecodeIndex: aBytecodeIndex.
	
	"If it is a backwards branch and we found no block with that bytecode index it is a split.
	Just keep track that the parent block falls through it"
	aBoolean ifTrue: [
		self
			trackIncomingBytecode: aBytecodeIndex - 1
			toBlock: block	 ].
	
	^ blocks add: block
]

{ #category : #'block-management' }
CEBlockListBuilder >> blockContainingInstruction: aBytecodeIndex [

	"Return the block contaning the bytecode index.
	I.e., the first block in the list which 
	 - bytecode index is smaller than the one searched
	 - has a next whose bytecode index is greater than the one searched "
	"Assume: blocks are sorted by bytecodeIndex"
	| previousBlock |
	previousBlock := blocks first.
	2 to: blocks size do: [ :index | | block |
		block := blocks at: index.
		block bytecodeIndex > aBytecodeIndex
			ifTrue: [ ^ previousBlock ].
		previousBlock := block ].
	^ previousBlock
]

{ #category : #accessing }
CEBlockListBuilder >> blocks [
	^ blocks
]

{ #category : #building }
CEBlockListBuilder >> build [
	
	"Calculate successors and predecessors from tracked incoming bytecode edges"
	incoming keysAndValuesDo: [ :block :incomingBytecodeIndexes |
		incomingBytecodeIndexes do: [ :bytecodeIndex | | predecessor |
			predecessor := self blockContainingInstruction: bytecodeIndex.
			predecessor addSuccessor: block.
			block addPredecessor: predecessor.
		]	
	].

	^ blocks
]

{ #category : #building }
CEBlockListBuilder >> buildBlocksFrom: aBytecodeMethod [ 
	
	| endPC |
	self bytecodeScanner: (InstructionStream on: aBytecodeMethod).
	currentBlock := self startOnBytecodeIndex: aBytecodeMethod initialPC.

	endPC := aBytecodeMethod endPC.	
	[bytecodeScanner pc <= endPC] whileTrue: [
		self interpretInstruction: [ bytecodeScanner interpretNextInstructionFor: self ].
	].

	^ self blocks
]

{ #category : #accessing }
CEBlockListBuilder >> bytecodeScanner: aBytecodeScanner [ 
	bytecodeScanner := aBytecodeScanner
]

{ #category : #accessing }
CEBlockListBuilder >> currentPC: anObject [
	currentPC := anObject
]

{ #category : #'private-building' }
CEBlockListBuilder >> doJumpTo: offset [

	| pcAfterJump jumpBlock targetPC |
	pcAfterJump := bytecodeScanner pc.
	"All jumps delimit blocks"
	self appendBlockAtBytecodeIndex: pcAfterJump.

	"Jump targets delimit blocks"
	targetPC := pcAfterJump + offset.
	jumpBlock := self appendBlockAtBytecodeIndex: targetPC isBackwardsBranch: offset < 0.
	offset < 0 ifTrue: [ jumpBlock incrementIncomingBackwardBranches ].
	
	"Keep track of back jumps.
	The incoming set of entries is used later to calculate successors at the end"
	self trackIncomingBytecode: currentPC toBlock: jumpBlock.
]

{ #category : #initialization }
CEBlockListBuilder >> initialize [
	super initialize.
	blocks := SortedCollection sortBlock: [ :a :b | a bytecodeIndex < b bytecodeIndex ].
	incoming := Dictionary new.
	instructionFactory := CEInstructionFactory new.
]

{ #category : #accessing }
CEBlockListBuilder >> instructionFactory: aCEInstructionFactory [ 
	instructionFactory := aCEInstructionFactory
]

{ #category : #building }
CEBlockListBuilder >> interpretInstruction: aBlockClosure [

	currentPC := bytecodeScanner pc.
	lastInstructionFellThrough := true.
	aBlockClosure value.
	currentBlock := blocks
		detect: [ :b | b bytecodeIndex = bytecodeScanner pc ]
		ifFound: [ :nextBlock |
			(lastInstructionFellThrough and: [ nextBlock ~~ currentBlock  ]) ifTrue: [ 
				self trackIncomingBytecode: currentPC - 1 toBlock: nextBlock ].
			nextBlock ]
		ifNone: [ currentBlock ].
]

{ #category : #'instruction decoding' }
CEBlockListBuilder >> jump: offset [

	self doJumpTo: offset.
	
	"Unconditional jumps do not fall through"
	lastInstructionFellThrough := false.
]

{ #category : #'instruction decoding' }
CEBlockListBuilder >> jump: offset if: aBoolean [

	self doJumpTo: offset
]

{ #category : #'instruction decoding' }
CEBlockListBuilder >> methodReturnConstant: aConstant [

	self return
]

{ #category : #'instruction decoding' }
CEBlockListBuilder >> methodReturnReceiver [

	self return
]

{ #category : #'instruction decoding' }
CEBlockListBuilder >> methodReturnTop [

	self return
]

{ #category : #'private-building' }
CEBlockListBuilder >> return [

	| pcAfterReturn |
	pcAfterReturn := bytecodeScanner pc.
	"Returns delimit blocks"
	pcAfterReturn > bytecodeScanner method endPC
		ifFalse: [ self appendBlockAtBytecodeIndex: pcAfterReturn ]
]

{ #category : #building }
CEBlockListBuilder >> startOnBytecodeIndex: aBytecodeIndex [

	currentBlock := self appendBlockAtBytecodeIndex: aBytecodeIndex
]

{ #category : #'block-management' }
CEBlockListBuilder >> trackIncomingBytecode: aBytecodeIndex toBlock: aBlock [
	"Keep track of back jumps.
	The incoming set of entries is used later to calculate successors at the end"
	(incoming at: aBlock ifAbsentPut: [ Set new ]) add: aBytecodeIndex.
]