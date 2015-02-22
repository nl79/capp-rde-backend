<cfscript>

component Request
	output="false"
	{
		
	property struct params; 
        
        Request function init(nodes) {
		
		/*
		 *check if the method is 'get' or 'post'.
		 *if 'get', parse the query string and set the params structure.
		 *if 'post', set the args object to point to the form object.
		 */
		
		if(this.isPost == true) {
			this.params = form; 
		} else if(this.isGet() == true) {
			this.params = this.parseQuery(); 
		}
		
		
		
		return(this);
	    
	}
	
	function parseQuery() {
		
		// get the query string
		var q = cgi.QUERY_STRING;
		
		//check if the query string is not empty.
		writedump(q); 
	}
	
	function getMethod() {
		return LCase(cgi.REQUEST_METHOD); 
	}
	
	function isPost() {
		return compare(this.getMethod(),'post') == 0? true: false; 
	}
	
	function isGet() {
		return compare(this.getMethod(),'get') == 0 ? true : false; 
	}
        
	
}

</cfscript>