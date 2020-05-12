Class {
	#name : #CECallGraphBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'pc'
	],
	#category : #'Altoque-Tests'
}

{ #category : #helpers }
CECallGraphBuilderTest >> pc [
	^ pc
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testBackwardsConditionalJumpAppendsBlockEndInstruction [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CECallGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder pushConstant: true.
	builder jump: -1 if: true.
		
	self assert: block lastInstruction isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testBackwardsConditionalJumpAppendsIfWithFallthroughJumpTarget [

	| block1 builder block2 |
	block1 := CEBlock new.
	block2 := CEBlock new.
	
	"The backwards jump"
	block1 incrementIncomingBackwardBranches.
	block1 addSuccessor: block1.
	block1 addPredecessor: block1.
	
	"The fallthrough block"
	block1 addSuccessor: block2.
	block2 addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . block2 };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to the same point."
	block1 bytecodeIndex: 0.
	block2 bytecodeIndex: 1.
	builder pushConstant: true.
	
	"The pc after the jump instruction"
	pc := block2 bytecodeIndex.
	builder jump: -1 if: true.
		
	self assert: block1 lastInstruction falseConditionJumpTarget equals: block2
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testBackwardsConditionalJumpAppendsIfWithJumpTarget [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CECallGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder pushConstant: true.
	builder jump: -1 if: true.
		
	self assert: block lastInstruction trueConditionJumpTarget equals: block
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testBackwardsJumpAppendsBlockEndInstruction [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CECallGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder jump: -1.
		
	self assert: block firstInstruction next isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testBackwardsJumpAppendsGotoWithJumpTarget [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CECallGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder jump: -1.
		
	self assert: block firstInstruction next jumpTarget equals: block
]

{ #category : #tests }
CECallGraphBuilderTest >> testBlocHasAsManyArgumentsAsMethod [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		initializeBlockArguments: block.
	self assert: block locals size equals: 2
]

{ #category : #tests }
CECallGraphBuilderTest >> testBlockWithOneIncomingBackwardBranchIsLoopHeader [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.
	
	self assert: block isLoopHeader
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testForwardConditionalJumpAppendsBlockEndInstruction [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testForwardConditionalJumpAppendsIfWithFallthroughJumpTarget [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end falseConditionJumpTarget equals: fallthroughBlock
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testForwardConditionalJumpAppendsIfWithJumpTarget [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end trueConditionJumpTarget equals: targetBlock
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testForwardJumpAppendsAppendsGotoWithJumpTarget [

	| builder block1 block2 |
	block1 := CEBlock new.
	block2 := CEBlock new.
	block1 addSuccessor: block2.
	block2 addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . block2 };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	block2 bytecodeIndex: 1.
	pc := 1.
	builder jump: 0.
		
	self assert: block1 firstInstruction next jumpTarget equals: block2
]

{ #category : #'tests-branchinstructions' }
CECallGraphBuilderTest >> testForwardJumpAppendsBlockEndInstruction [

	| builder block1 block2 |
	block1 := CEBlock new.
	block2 := CEBlock new.
	block1 addSuccessor: block2.
	block2 addPredecessor: block1.

	builder := CECallGraphBuilder new
		blockList: { block1 . block2 };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	block2 bytecodeIndex: 1.
	pc := 1.
	builder jump: 0.
		
	self assert: block1 firstInstruction next isBlockEnd
]

{ #category : #tests }
CECallGraphBuilderTest >> testInitializeLoopHeaderBlocArgumentsHasPhiFunctions [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		initializeBlockArguments: block.
	self assert: (block locals allSatisfy: [ :e | e isPhi ])
]

{ #category : #'tests-pushinstructions' }
CECallGraphBuilderTest >> testPushConstantAppendsConstantInstruction [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushConstant: 17.
		
	self assert: block firstInstruction next isConstant.
	self assert: block firstInstruction next value equals: 17.
]

{ #category : #'tests-pushinstructions' }
CECallGraphBuilderTest >> testPushLiteralAppendsLiteralInstruction [

	| block literal |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	literal := #Global -> 17.
	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushLiteralVariable: literal.
		
	self assert: block firstInstruction next isLiteralVariable.
	self assert: block firstInstruction next value equals: literal.
]

{ #category : #'tests-pushinstructions' }
CECallGraphBuilderTest >> testPushReceiverDoesNotAppendReceiverInstruction [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushReceiver.
		
	self assert: block firstInstruction next isNil
]

{ #category : #'test-sendInstructions' }
CECallGraphBuilderTest >> testSendBinaryAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		pushConstant: 2;
		send: #+ super: false numArgs: 1.
		
	self assert: block firstInstruction next next next selector equals: #+
]

{ #category : #'test-sendInstructions' }
CECallGraphBuilderTest >> testSendKeywordAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		pushConstant: 2;
		send: #keyword: super: false numArgs: 1.
		
	self assert: block firstInstruction next next next selector equals: #keyword:
]

{ #category : #'test-sendInstructions' }
CECallGraphBuilderTest >> testSendUnaryAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CECallGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		send: #unary super: false numArgs: 0.
		
	self assert: block firstInstruction next next selector equals: #unary
]