exampleJSON = '{
	"worldName": "Test world",
	"createdBy": "Richard Brown",
	"intro": "You awaken, you are dazed and have no idea how you got here.  You dont understand why, but you know you need to escape.",
	"rooms": [
		{
			"Name": "Two Doors",
			"shortDesc": "You are in an empty room with two doors.",
			"paths": [
				{
					"direction": "north",
					"dest": 1
				},
				{
					"direction": "east",
					"dest": 
				}
			]
		},
		{
			"Name": "Empty Room",
			"shortDesc": "You find yourself in a bland magnolia room with nothing in it.",
			"paths": [
				{
					"direction": "south",
					"dest": 0
				}
			]
		},
		{
			"Name": "Hallway",
			"shortDesc": "You are in a majestic hallway, lit from some unknown source.",
			"paths": [
				{
					"direction": "west",
					"dest": 0
				},
				{
					"direction": "east",
					"dest": 3
				}
			]
		},
		{
			"Name": "Another Dead End",
			"shortDesc": "You find yourself in a concrete room, with bland grey walls.",
			"paths": [
				{
					"direction": "west",
					"dest": 2
				}
			]
		}
	]
}'

#The Core game engine
class FuzzyEngineCore
	writeResponse = null
	writeWarning = null
	writeError = null
	writeLog = null
	world = null
	currentRoom = null
	parser = null

	#Constructor requires a set of output methods to use.
	constructor: (outputMethods) ->
		writeResponse = (x) -> outputMethods.writeResponse(x)
		writeWarning =  (x) -> outputMethods.writeWarning(x)
		writeError =    (x) -> outputMethods.writeError(x)
		writeLog =      (x) -> outputMethods.writeLog(x)

		parser = new TextParser

		writeLog("FuzzyCoreEngine on-line")

	loadFromJSON: (worldJSON) ->
		writeLog("Loading World...")

		try
			world = JSON.parse(worldJSON)
		catch err
			writeError("Failed to open World - " + err.toString())
			false

		writeLog("World successfully loaded")
		writeLog("  Name:       " + world.worldName)
		writeLog("  Created by: " + world.createdBy)
		writeLog("  Rooms:      " + world.rooms.length)
		true

	startGame: ->
		if world == null
			writeError("No world loaded yet!")
			false
		if currentRoom == null
			writeResponse(world.intro)
			currentRoom = world.rooms[0]
			writeResponse(currentRoom.shortDesc)
			writeResponse("There is an exit to the " + path.direction) for path in currentRoom.paths
			true
		else
			writeError("Cannot start a game already in progress")
			false

	processInput: (userInput) ->
		result = parser.parse(userInput)
		if result == null
			writeResponse("I don't know how to do that.")
		else
			writeResponse(userInput)


#Parser class used to standardize inputs from users by engine
class TextParser
	parse: (input) ->
		words = input.match(/\S+/g)
		null


#Actions and simpler ones GO EAST (MOVE EAST null), USE the KEY on the LOCKED DOOR (USE KEY LOCKED_DOOR), i SMASH the CHEST with my AXE (SMASH CHEST AXE).
class PlayerAction
	constructor: (@action, @primaryObject, @secondaryObject) ->


#Objects are a combination of a 1 noun and 0..* verbs, that can be compared at different levels
class WorldObject
	constructor: (@object, @descriptors) ->

	getObject: -> @object

	getDescriptors: -> @descriptors

	toString: -> @descriptors.join(" ") + " " + @object

	# 0 = No match, 1 = Noun match only, 2 = that verbs is subset of this verbs and noun match, 3 = full match
	matchWith: (that) ->
		return 0 if @object != that.getObject
		return 1 for verb in that.getDescriptors when !@descriptors.indexOf(verb) > -1
		return 2 if that.getDescriptors.length != @descriptors.length
		return 3


#StandardOutput contains 4 functions to handle text outputs
class StandardOutput
	writeResponse: (x) -> console.log(x)                  #What the user reads as part of normal game flow
	writeWarning:  (x) -> console.info("WARNING: " + x)   #Warning messages that show there may be a problem with the engine
	writeError:    (x) -> console.error(x)                #Error messages where something has gone wrong
	writeLog:      (x) -> console.info("SYS LOG: " + x)   #Logging messages from the engine


#TestCode
testEngine = new FuzzyEngineCore(new StandardOutput)
testEngine.loadFromJSON(exampleJSON)
testEngine.startGame()
testEngine.processInput("Go east")
