Node <- setRefClass("Node",
	fields = list(previousNode = "ANY", nextNode = "ANY", element = "ANY"),
	methods = list(
		initialize = function(element) {
			element <<- NULL
			previousNode <<- NULL
			nextNode <<- NULL
		},
	
		getPreviousNode = function() {previousNode},
		getNextNode = function() {nextNode},
		getElement = function() {element},
		
		setPreviousNode = function(newNode) {previousNode <<- newNode},
		setNextNode = function(newNode) {nextNode <<- newNode},
		setElement = function(object) {element <<- object}
	)
)

LinkedList <- setRefClass("LinkedList",
	fields = list(headNode = "ANY", tailNode = "ANY", size = "numeric", sorted = "logical"),
	methods = list(
		initialize = function() {
			sorted <<- FALSE
			headNode <<- NULL
			tailNode <<- NULL
			size <<- 0
		},

		setSorted = function() {
			sorted <<- TRUE
		},
		
		compare = function(element1, element2) {
			if (element1 < element2)
				-1
			else if (element1 > element2)
				1
			else 0
		},
		
		sortLastNode = function() {
			currentNode = tailNode
		
			while (compare(currentNode, currentNode$previousNode()) < 0) {
				tempNode <- currentNode$getPreviousNode()
				tempNodeNext <- currentNode$getNextNode()
				
				currentNode$setPreviousNode(tempNode$getPreviousNode())
				currentNode$setNextNode(tempNode)
				if (!is.null(currentNode$getPreviousNode))
					currentNode$previousNode$setNextNode(currentNode)
				
				tempNode$setPreviousNode(currentNode)
				tempNode$setNextNode(tempCurrentNodeNext)
				if (!is.null(tempCurrentNodeNext))
					tempNodeNext$setPreviousNode(tempNode)
				
				if (tempNode == headNode){
					headNode <<- currentNode
					break
				}
				if (currentNode == tailNode) {
					tailNode <<- tempNode
				}
			}
		},
		
		add = function(object) {
		
			node <- Node$new()
			node$setElement(object)
			
			if (size == 0) {
				headNode <<- node
				tailNode <<- node
			} else {
				node$setPreviousNode(tailNode)
				tailNode$setNextNode(node)
				tailNode <<- node
			}
		
			size <<- size + 1
		},
		
		remove = function() {
			if (size == 0) return()
			
			returnElement <- headNode$getElement()
			
			if (size == 1) {
				headNode <<- NULL
				tailNode <<- NULL
			} else {
				headNode$setNextNode(NULL)
				headNode <<- headNode$getNextNode()
				headNode$setPreviousNode(NULL)
			}
			
			size <<- size - 1
			returnElement
		}
	)
)