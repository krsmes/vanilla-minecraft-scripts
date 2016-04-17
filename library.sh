
: ${MC_DIR='.'}
: ${MC_SCREEN_NAME='mc'}
: ${MC_SERVER_JAR='minecraft_server.jar'}
: ${MC_JAVA_MEM='-Xmx4G -Xms4G'}
# : ${MC_JAVA_OPTS='-XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+UseNUMA -XX:+CMSParallelRemarkEnabled -XX:MaxTenuringThreshold=15 -XX:MaxGCPauseMillis=30 -XX:GCPauseIntervalMillis=150 -XX:+UseAdaptiveGCBoundary -XX:-UseGCOverheadLimit -XX:+UseBiasedLocking -XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=15 -Dfml.ignorePatchDiscrepancies=true -Dfml.ignoreInvalidMinecraftCertificates=true -XX:+UseFastAccessorMethods -XX:+UseCompressedOops -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:ReservedCodeCacheSize=1536m -XX:+UseCodeCacheFlushing -XX:SoftRefLRUPolicyMSPerMB=20000 -XX:ParallelGCThreads=10'}


new_world() {
	rm -rf "$MC_DIR/world"
}

start() {
	echo "##  Starting screen '$MC_SCREEN_NAME' using $server_jar"
	screen -dmS $MC_SCREEN_NAME java $MC_JAVA_MEM -jar "$MC_DIR/$MC_SERVER_JAR" nogui
	screen -ls
}

start_new_world() {
	echo "##  Creating new world..."
	new_world
	start
}

taillog() {
	tail -n 100 -f "$MC_DIR/logs/latest.log"
}

send() {
	local cmd=$*
	echo "### Sending command: '$cmd'"
	screen -x $MC_SCREEN_NAME -p 0 -X stuff "${cmd}"$'\r'
}

attach() {
	screen -x $MC_SCREEN_NAME
}

close() {
	screen -x $MC_SCREEN_NAME -p 0 -X quit
	screen -ls
}

stop() {
	send 'say Stopping now'
	sleep 1
	send '/stop'
	sleep 5
	close
}

stop_with_warning() {
	send 'say Stopping in 10 seconds!'
	sleep 10
	stop
}

save_world() {
	send '/save-all'
}


save_playerdata() {
	mkdir -p "$MC_DIR/playerdata"
	cp -R "$MC_DIR/world/playerdata/" "$MC_DIR/playerdata"
}

restore_playerdata() {
	mkdir -p "$MC_DIR/world/playerdata"
	cp -R "$MC_DIR/playerdata/" "$MC_DIR/world/playerdata"
}


_fileYMD() { 
	echo $(stat -f '%Sm' -t '%Y%m%d' $1) 
}

_fileYMDHM() { 
	echo $(stat -f '%Sm' -t '%Y%m%d%H%M' $1) 
}

backup_world() {
	cp -R "$MC_DIR/world" "$MC_DIR/world.$(_fileYMDHM world)"
}

archive_world() {
	mv "$MC_DIR/world" "$MC_DIR/world.$(_fileYMD world)"
}
