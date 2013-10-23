BubbleQueue <- setRefClass("BubbleQueue",
	fields = list(bqList = "list", elementCount = "numeric"),
	methods = list(

		initialize = function() {
			bqList <<- list()
			elementCount <<- 0
		},
		
		reset = function() {
			bqList <<- list()
			elementCount <<- 0
		},
		
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
	
		add = function(object) {
			elementCount <<- elementCount + 1
			
			objectPosition = length(bqList) + 1
			bqList[[objectPosition]] <<- object
			while(objectPosition != 1 && compare(object, bqList[[objectPosition - 1]]) < 0) {
				bqList[[objectPosition]] <<- bqList[[objectPosition - 1]]
				bqList[[objectPosition - 1]] <<- object
				objectPosition <- objectPosition - 1
			}
		},
		
		remove = function() {
			if (elementCount > 0) {
				elementCount <<- elementCount - 1
			
				returnVal = bqList[[1]]
				bqList[[1]] <<- NULL
				returnVal
			}
			else NULL
		},
		
		peek = function() {
			bqList[[1]]
		}
	
	)
)