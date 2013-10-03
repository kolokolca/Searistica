#source("LinkedList.R")

#This class represents a calendar queue, a type of priority queue that makes the assumption that all values added will be greater than the current least.

CalendarQueue <- setRefClass("CalendarQueue",
	fields = list(cqList = "list", bucketSize = "numeric", listSize = "numeric", elementCount = "numeric", position = "numeric", baseValue = "numeric"),
	methods = list(

		initialize = function() {
			cqList <<- list()
			bucketSize <<- 1
			listSize <<- 2
			elementCount <<- 0
			position <<- 1
			baseValue <<- 0
		},
		
		reset = function() {
			cqList <<- list()
			bucketSize <<- 1
			listSize <<- 2
			elementCount <<- 0
			position <<- 1
			baseValue <<- 0
		},
	
		#This function provides an objects priority. It is intended to be overwritten with a custom priority definition.
	
		#This method returns -1 if object1 comes before object2, 1 if after, and 0 if they have the same priority.
		compare = function(object1, object2) {

			if (getPriority(object1) < getPriority(object2))
				-1
			else if (getPriority(object1) > getPriority(object2))
				1
			else 0
		},
	
		#Returns the priority of the given object.
		getPriority = function(object) {
			if (typeof(object) == "S4") {
				object@priority
			} else {
				object
			}
		},
	
	
		#Could be made more efficient by not removing elements


		#Determines the average spacing between elements for the purposes of bucket resizing.
		#Calculations are performed by sampling the first several elements.
		#The elements are not returned to the list, as it is assumed the current list will be replaced.
		calculateAverageSeparation = function() {
			backupBaseValue <- baseValue
			
			sampleValues = list()
			
			for (i in 1:min(10, elementCount)) {
				sampleValues[[i]] <- remove(FALSE)
			}

			totalSeparation = 0
			if (length(sampleValues) > 1) {
				for (i in 1:(length(sampleValues) - 1)) {
					totalSeparation <- totalSeparation + abs(getPriority(sampleValues[[i]]) - getPriority(sampleValues[[i + 1]]))
				}
			}
			
			baseValue <<- backupBaseValue
			
			if (totalSeparation == 0)
				totalSeparation <- 1
			else
				totalSeparation / (length(sampleValues) - 1)
		},
		
		#Returns true if the given index in the given list is null or out of bounds.
		isEmpty = function(aList, index) {			
			(floor(index) > length(aList)) || is.null(aList[[index]])
		},
		
		#increments counter to next value
		#increase baseValue
		incrementPosition = function() {
			if (elementCount == 0) {
				return()
			}
		
			while (TRUE) {
				if (isEmpty(cqList, position) || isEmpty(cqList[[position]], 1) || getPriority(cqList[[position]][[1]]) >= baseValue + bucketSize * 2) {
				
					position <<- max((position + 1) %% (listSize + 1), 1)
					baseValue <<- baseValue + bucketSize
					next
				}
				else
					break 
			}
		},
		
		#could be made more efficient by reusing original array
		
		#Transfers objects from the given list into the current cqList.
		addObjects = function(tempList) {
				
			while(length(tempList) > 0) {
				if (isEmpty(tempList, 1) || isEmpty(tempList[[1]], 1)) {
					tempList[1] <- NULL
					next
				}
				else {
					add(tempList[[1]][[1]])
					tempList[[1]][[1]] <- NULL
					next				
				}
			}
		},
		
		#Could be made more efficient by reusing original array
		
		#doubles cqList size
		#calls calculateaverageseparation and changes bucketsize accordingly
		#resets counter position
		
		#Doubles cqList size
		increaseQueueSize = function() {		
			
			tempList <- cqList
			bucketSize <<- calculateAverageSeparation()
			cqList <<- list()
			elementCount <<- 0
			position <<- 1
			listSize <<- listSize * 2
			
			addObjects(tempList)		
		},
		
		#Could be made more efficient by reusing original array
		
		#halves cqList size
		#calls calculateaverageseparation and changes bucketsize accordingly
		#resets counter position
		
		#Halves cqList size
		decreaseQueueSize = function() {
			
			tempList <- cqList
			bucketSize <<- calculateAverageSeparation()
			cqList <<- list()
			elementCount <<- 0
			position <<- 1
			listSize <<- listSize / 2
			
			addObjects(tempList)
		},
		
		#Could be made more efficient by using linked list
		
		#Can call increasequeuesize
		
		#Adds an element to the queue.
		#Calls increaseQueueSize when the number of elements is greater than twice the size of the current cqList size.
		#The calls to increaseQueueSize can be turned off by setting advancePosition to FALSE.
		add = function(object, advancePosition = TRUE) {
			elementCount <<- elementCount + 1
		
		
			objectPosition <- 1
			if (baseValue + bucketSize >= getPriority(object)) {
				objectPosition <- position
			} else {
				#(position - 1) acts like the list index starts at 0, the - 1 at the end and the listSize + 1 also account for the indexing starting at 1 instead of 0.
				objectPosition <- ((position - 1) + (getPriority(object) - baseValue) / bucketSize - 1) %% listSize + 1
			}
			
			if (isEmpty(cqList, objectPosition)) {
				cqList[[objectPosition]] <<- list()
			}			
			
			objectSubPosition <- length(cqList[[objectPosition]]) + 1
			cqList[[objectPosition]][[objectSubPosition]] <<- object
			while(objectSubPosition != 1 && compare(object, cqList[[objectPosition]][[objectSubPosition - 1]]) < 0) {
				cqList[[objectPosition]][[objectSubPosition]] <<- cqList[[objectPosition]][[objectSubPosition - 1]]
				cqList[[objectPosition]][[objectSubPosition - 1]] <<- object
				objectSubPosition <- objectSubPosition - 1
			}
			
#			if (advancePosition) {
#				incrementPosition()
#			}
			if (elementCount > (listSize * 2)) {
				increaseQueueSize()
			}
		},
		
		#Could be made more efficient with some kind of linked list
		
		#Removes the highest/lowest priority element (based on how priority is defined) and returns it.
		#Calls decreaseQueueSize when the number of elements is less than half the current cqList size.
		#The calls to decreaseQueueSize can be turned off by passing FALSE as a parameter, which is useful when calculateAverageSeparation is called.
		remove = function(decreaseQueueIfNecessary = TRUE) {
			if (elementCount > 0) {
				incrementPosition()
				elementCount <<- elementCount - 1
			
				returnVal <- cqList[[position]][[1]]
				cqList[[position]][[1]] <<- NULL
				if (elementCount > 2 && elementCount < (listSize / 2) && decreaseQueueIfNecessary) {
					decreaseQueueSize()
				}
				
				returnVal
			}
			else NULL
		},
		
		#Returns the element with the highest/lowest priority depending on how priority is defined.
		#Additional steps are taken to ensure no changes are made to the list.
		peek = function() {
			if (elementCount > 0) {
				originalPosition <- position
				originalBaseValue <- baseValue
				incrementPosition()
				
				returnVal <- cqList[[position]][[1]]
				
				position <<- originalPosition
				baseValue <<- originalBaseValue
				
				returnVal
			}
			else NULL
		}
	)
)