#!/usr/bin/env groovy

@Grab(group='com.flowpowered', module='flow-nbt', version='1.0.0')
import com.flowpowered.nbt.stream.*
import com.flowpowered.nbt.*

import java.io.*
import java.util.regex.*

def mcScreenName = 'mc'
def mcLogFile = 'logs/latest.log'
def mcSavedPlayerDataDir = 'playerdata'
def mcWorldPlayerDataDir = 'world/playerdata'

/* 
 * file tail reader 
 */

class TailReader {
    static REFRESH_RATE = 100
    private File file 
    private boolean stop = false
    TailReader(File f) { 
        file = f 
        if (!file.exists()) throw new RuntimeException("${file.name} does not exist")
    }
    TailReader(String fname) { this(new File(fname)) }
    void stop() { stop = true }
    void tail(Closure c) {
        new Thread({
            def line
            long lastPos = file.length() // start at then end
            while (!stop) {
                def fileAccess = new RandomAccessFile(file, 'rw')                
                def len = fileAccess.length()
                if (len > lastPos) {
                    // go the end
                    fileAccess.seek(lastPos)
                    // read and process all new lines
                    while ((line = fileAccess.readLine()) != null) { c(line) }
                    // update end pointer
                    lastPos = fileAccess.filePointer
                }
                fileAccess.close()
                sleep(REFRESH_RATE)
            } 
        }).start()
    }
}


/* 
 * nbt tag functions 
 */

def readTag = { file ->
  new NBTInputStream(file.newInputStream(), true).readTag()
}

def writeTag = { file, Tag tag ->
  def n = new NBTOutputStream(file.newOutputStream(), true)
  n.writeTag(tag)
  n.close()
}


/* 
 * send command to minecraft server using screen 
 */
def sendCommand = { cmd -> 
    ['screen', '-x', mcScreenName, '-p', '0', '-X', 'stuff', cmd + '\r'].execute().waitFor()
}


/*
 * copy old playerdata to new world/playerdata keeping new position
 * and resetting health/foodlevel
 */
def checkPlayerData = { user, uuid ->
    def oldDataFile = new File("$mcSavedPlayerDataDir/${uuid}.dat")
    if (oldDataFile.exists()) {
        // kick them off
        println "$user has playerdata"
        sendCommand "/kick $user Updating inventory, please reconnect in 5 seconds"
        sendCommand "/save-all"
        sleep 1000

        // read their current position
        def newDataFile = new File("$mcWorldPlayerDataDir/${uuid}.dat")
        while (!newDataFile.exists()) { sleep 500 }
        def newData = readTag(newDataFile)
        (x, y, z) = newData.value['Pos']?.value?.collect { it.value }
        println "$user is at $x, $y, $z"

        // read their old data file and update it with new position and reset health
        def oldData = readTag(oldDataFile)
        oldData.value['Pos'] = new ListTag('Pos', DoubleTag, [new DoubleTag("",x), new DoubleTag("",y), new DoubleTag("",z)])
        oldData.value['Health'] = new FloatTag('Health', 20.0)
        oldData.value['Fire'] = new ShortTag('Fire', (short)-20)
        oldData.value['foodLevel'] = new IntTag('foodLevel', 20)
        oldData.value['foodExhaustionLevel'] = new FloatTag('foodExhaustionLevel', 0.0)

        // overwrite their current playerdata file with the updated old player data
        writeTag(newDataFile, oldData)
        println "$user playerdata updated"
    }
}


/*
 * minecraft event handlers
 */

def login = { user, uuid -> 
    println "$user logged in with UUID of $uuid"
    // check to see if they already have a playerdata file or not
    def exists = new File("$mcWorldPlayerDataDir/${uuid}.dat").exists()
    sleep 5000  // give them 5 seconds to finish login
    sendCommand "say ${exists?'Welcome back':'Welcome'} $user"
    if (!exists) { 
        // first login to this world...
        checkPlayerData(user, uuid) 
    }
}

def logout = { user -> 
    println "$user logged out" 
}

def message = { user, message -> 
    println "$user said '$message'" 
}

def action = { user, action -> 
    println "$user did '$action'" 
}


/* 
 * minecraft log file event processor 
 */
static List getm() { Matcher.lastMatcher[0] }  // 'm[]'
new TailReader(mcLogFile).tail { 
    //println "## DEBUG: $it"
    switch (it) {
        // [User Authenticator #1/INFO]: UUID of player krsmes is c45ccd5f-adec-4f18-884a-bc3c9dc3dab4
        case ~/.*\[User Authenticator.*\]: UUID of player (.+) is (.+)$/: 
            login(m[1], m[2]); break

        // [Server thread/INFO]: krsmes left the game
        case ~/.*\[Server.*\]: (.+) left the game$/:
            logout(m[1]); break

        // [Server thread/INFO]: <krsmes> yo
        case ~/.*\[Server.*\]: \<(.+)\> (.*)$/:
            message(m[1], m[2]); break

        // [Server thread/INFO]: [krsmes: Set the time to 0]
        case ~/.*\[Server.*\]: \[(.+): (.*)\]$/:
            action(m[1], m[2]); break
    }
}

/* 
 * keep alive 
 */
println "Watching ${mcLogFile} for events..."
while (true) sleep(1000)
