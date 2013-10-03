#This class represents the traditional priority queue.

PriorityQueue <- setRefClass("PriorityQueue",
	fields = list(pqList = "list", elementCount = "numeric"),
	methods = list(

		initialize = function() {
			pqList <<- list()
			elementCount <<- 0
		},
		
		reset = function() {
			pqList <<- list()
			elementCount <<- 0
		},
			
		#This method determines the relative ordering of two objects. Returns -1 if object1 comes before obejct2, 1 if object1 comes after, or 0 if they are equal.
		#This method is meant to be overwritten to change the relative ordering of objects or for more complex evaluations. It must be overwritten for any objects without a defined natural ordering.
		compare = function(object1, object2) {

			if (getPriority(object1) < getPriority(object2))
				-1
			else if (getPriority(object1) > getPriority(object2))
				1
			else 0
		},
	
		getPriority = function(object) {
		
			if (typeof(object) == "S4") {
				object@priority
			} else {
				object
			}
		},
		
		#Moves a newly added up the priority queue.
		swim = function(position) {
			if (position > 1 && position <= length(pqList) && compare(pqList[[position]], pqList[[floor(position/2)]]) < 0) {
				temp <- pqList[[position]]
				pqList[[position]] <<- pqList[[floor(position/2)]]
				pqList[[floor(position/2)]] <<- temp
				
				swim(floor(position/2))
			}
		},
		
		#Moves a value down the priority queue.
		sink = function(position) {
			if (length(pqList) >= 2 * position) {
				child <- -1
				if (compare(pqList[[position]], pqList[[position * 2]]) > 0)
					child <- position * 2
				if (length(pqList) >= 2 * position + 1 && compare(pqList[[position]], pqList[[position * 2 + 1]]) > 0)
					if (child == -1 || compare(pqList[[child]], pqList[[position * 2 + 1]]) > 0)
						child <- position * 2 + 1
				
				if (child != -1) {
					temp <- pqList[[position]]
					pqList[[position]] <<- pqList[[child]]
					pqList[[child]] <<- temp
					
					sink(child)
				}
			}
		},
	
		#Adds an object to the priority queue.
		add = function(object) {
			pqList[[length(pqList) + 1]] <<- object
			swim(length(pqList))
			elementCount <<- elementCount + 1
		},
		
		#Reveals the next object in the priorty queue without removing it.
		peek = function() {
			if (length(pqList) >= 1) {
				pqList[[1]]
			}
			else NULL
		},
		
		#Reveals the next object in the priority queue and removes it.
		remove = function() {
			if (length(pqList) >= 1) {
				returnVal <- pqList[[1]]
				pqList[[1]] <<- pqList[[length(pqList)]]
				length(pqList) <<- length(pqList) - 1
				sink(1)
				elementCount <<- elementCount - 1
				returnVal
			}
			else NULL
		}
	)
)