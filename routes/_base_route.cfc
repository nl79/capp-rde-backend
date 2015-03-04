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
	
	/*
	 *@method: userValid() - checks if the user data is valid and the user is logged in.
	 */
	function userValid() {
	        
	    var sess = GetPageContext().GetSession();;
	    
	    
	    flag = sess.getValue('valid');
	    
	    if(isDefined("flag") && compare('true', flag) == 0) {
		
		return true; 
	    } else {
		
		//redirect to the login page.
		location('/account/login');
		exit;
		
	    }
	    
	} 
}

</cfscript>