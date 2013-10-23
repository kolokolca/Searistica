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
				priority(object)
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
			
				print("***")
				print("isEmpty(cqList, position)")
				print(isEmpty(cqList, position))
				print("isEmpty(cqList[[position]], 1)")
				print(isEmpty(cqList[[position]], 1))
				print("getPriority(cqList[[position]][[1]]) >= baseValue + bucketSize * 2")
				print(getPriority(cqList[[position]][[1]]) >= baseValue + bucketSize * 2)
			
			
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
					add(tempList[[1]][[1]], FALSE)
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
			if (baseValue >= getPriority(object)) {
				objectPosition <- position
			} else {
				objectPosition <- ((position - 1) + (getPriority(object) - baseValue) / bucketSize - 1) %% listSize + 1
			}
			
		#	print(objectPosition)
			
			if (isEmpty(cqList, objectPosition)) {
				cqList[[objectPosition]] <<- list()
			}			
			
			if (length(cqList[[objectPosition]]) > 0) {
				firstIndex <- 1
				lastIndex <- length(cqList[[objectPosition]]) + 1
				midIndex <- floor(firstIndex + (lastIndex - firstIndex) / 2)
				value <- getPriority(object)
				
				while (firstIndex < lastIndex || value == cqList[[objectPosition]][[midIndex]]) {
				
				
					print("%%%")
					print(length(cqList[[objectPosition]]))
					print(firstIndex)
					print(midIndex)
					print(lastIndex)
				
					midIndex <- floor(firstIndex + max((lastIndex - firstIndex) / 2, 1))
					
					if (midIndex > length(cqList[[objectPosition]]) || midIndex < 1)
						break
					
					if (compare(cqList[[objectPosition]][[midIndex]], object) < 0) {
						firstIndex <- midIndex + 1
					} else {
						lastIndex <- midIndex - 1
					}
				}
				
				if (midIndex> length(cqList[[objectPosition]])) {
					cqList[[objectPosition]][[length(cqList[[objectPosition]]) + 1]] <<- object
				}else if (compare(cqList[[objectPosition]][[midIndex]], object) > 0) {
				
					cqList[[objectPosition]] <<- mapply(c, cqList[[objectPosition]][1:(midIndex)], list(object), cqList[[objectPosition]][(midIndex + 1):length(cqList[[objectPosition]])], SIMPLIFY=FALSE)
				} else {
					if (midIndex == 0) {
						cqList[[objectPosition]] <<- mapply(c, list(object), cqList[[objectPosition]][midIndex:length(cqList[[objectPosition]])])
					} else {
						print("b")
						cqList[[objectPosition]] <<- mapply(c, cqList[[objectPosition]][1:(midIndex - 1)], list(object), cqList[[objectPosition]][midIndex:length(cqList[[objectPosition]])], SIMPLIFY=FALSE) 
					}
					
					
				}
			} else {
				cqList[[objectPosition]][[1]] <<- object
			}
			
			
			
			
			
			
			thisiswhatimtesting <- function() {
			objectSubPosition <- length(cqList[[objectPosition]]) + 1
			cqList[[objectPosition]][[objectSubPosition]] <<- object
			while(objectSubPosition != 1 && compare(object, cqList[[objectPosition]][[objectSubPosition - 1]]) < 0) {
				cqList[[objectPosition]][[objectSubPosition]] <<- cqList[[objectPosition]][[objectSubPosition - 1]]
				cqList[[objectPosition]][[objectSubPosition - 1]] <<- object
				objectSubPosition <- objectSubPosition - 1
			}

			}
			#thisiswhatimtesting()
			
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
			else NA
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
			else NA
		}
	)
)