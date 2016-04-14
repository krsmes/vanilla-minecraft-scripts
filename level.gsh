#!/usr/bin/env groovy

@Grab(group='com.flowpowered', module='flow-nbt', version='1.0.0')
import com.flowpowered.nbt.stream.*
import com.flowpowered.nbt.*

def worldDataFile = 'world/level.dat'
def playerDataDir = 'world/playerdata'


def readTag = { file ->
	new NBTInputStream(file.newInputStream(), true).readTag()
}

def writeTag = { file, Tag tag ->
	def n = new NBTOutputStream(file.newOutputStream(), true)
	n.writeTag(tag)
	n.close()
}

def tagDataValue = { Tag tag, String name -> tag.value.Data.value[name].value }
def tagValue = { Tag tag, String name -> tag.value[name]?.value }

def iteratePlayers = { folder, Closure c ->
	folder.eachFile { f -> c(f, readTag(f)) }
}

def showPlayerInfo = { playerDir ->
	iteratePlayers(new File(playerDir)) { file, tag ->
		pos = tagValue(tag, 'Pos')?.collect { it.value }
		spawn = [tagValue(tag, 'SpawnX'), tagValue(tag, 'SpawnY'), tagValue(tag, 'SpawnZ')]
		spawnForced = tagValue(tag, 'SpawnForced')
		foodLevel = tagValue(tag, 'foodLevel')
		foodExhaustionLevel = tagValue(tag, 'foodExhaustionLevel')
		// println "\n$file.name:\n$tag\n"
		println "Pos=$pos, Spawn=$spawn (forced:$spawnForced), Food=$foodLevel (exhaustion:$foodExhaustionLevel)"
	}
}

def updatePlayerInfo = { playerDir ->
	iteratePlayers(new File(playerDir)) { file, tag ->
		tag.value['Health'] = new FloatTag('Health', 20.0)
		tag.value['Fire'] = new ShortTag('Fire', (short)-20)
		tag.value['foodLevel'] = new IntTag('foodLevel', 20)
		tag.value['foodExhaustionLevel'] = new FloatTag('foodExhaustionLevel', 0.0)
		writeTag(file, tag)
	}
}


world = readTag(new File(worldDataFile))
spawnX = tagDataValue(world, 'SpawnX')
spawnY = tagDataValue(world, 'SpawnY')
spawnZ = tagDataValue(world, 'SpawnZ')
// println "\nWorld:\n$world\n"
println "Spawn: $spawnX,$spawnY,$spawnZ"

println "----"
// updatePlayerInfo(playerDataDir)
showPlayerInfo(playerDataDir)
