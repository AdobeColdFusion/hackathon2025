
component {
	this.name = "cfgrid2";
    this.sessionManagement = true;
    this.SessionTimeout = CreateTimeSpan( 0, 0, 90, 0 );
    this.scriptProtect="none";
    function onApplicationStart(){
        // Instantiation state on first application load
    }
    function onSessionStart(){
        // Instantiation  state on first session load
    }
    function onRequestStart(){
        // Instantiation  state on first request load
        //applicationStop();
    }
}