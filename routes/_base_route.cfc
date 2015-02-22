<cfscript>

component _base_route
	output="false"
	{
    	    
        /*
	 *base route constructor
	 */
        _base_route function init() {
            
	    return( this ); 
        }
	
	/*
	 *@method: getSession() - return a reference to the current session object
	 */
	function getSession() {
	    return GetPageContext().GetSession(); 
	}
	
	/*
	 *@method: getRequest() - Build a request componenet and return a reference
	 */
	function getRequest() {
	    return new components.Request(); 
	}
        
}

</cfscript>