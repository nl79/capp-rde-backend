<cfscript>

component Request
	output="false"
	{
		
	property params; 
        
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
		
		//create a new structure.
		var params = StructNew();
		
		//check if the query string is not empty.
		if(len(q) > 0) {
			
			//split the string on &;
			var parts = q.split('&');
			
			
			
			/*
			 * loop through the parts array.
			 * split the string on '=' and store the key value pairs.
			 */
			for (i=1; i<=arrayLen(parts); i++) {
				
				//check that the string is not empty and split on &
				if(len(parts[i] > 0)) {
					
					var pair = parts[i].split('=');
					
					//check that the array length is 2 and set the struct variables.
					if(ArrayLen(pair) == 2) {
						
						//if the array key does not exists, set the key and value
						if(!StructKeyExists(params, pair[1])) {
							
							StructInsert(params, pair[1], pair[2]); 
						}
					}
					 
				}
			}

		}
		
		return params; 
	}
	
	function getData(key) {
		//make sure key is supplied and is string
		if(isDefined('key') && Compare(getMetadata(key).getName(), 'java.lang.String') == 0) {
			
			//check if the key is set in the params structure.
			return StructKeyExists(this.params, key) ? this.params[key] : null; 
		}
		
		//return null by default. 
		return null; 
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