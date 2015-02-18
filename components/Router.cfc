<cfscript>

component Router
	output="false"
	{
        
	property array nodes; 
        property string route;
        property string action; 
        
        Router function init(nodes) {
		this.nodes = nodes;
		
		/*
		 *validate the node array length and set the route and action variables.
		 *if a value is not present, set it to 'index' as default. 
		 */
		 
		this.route = ArrayLen(this.nodes) >= 1 ? this.nodes[1] : "index"; 
	    
		this.action = ArrayLen(this.nodes) >= 2 ? this.nodes[2] : "index";     
	    
		return(this);
	    
	}
        
        function getRoute() {
		
		return this.route; 
        }
        
        function getAction() {
		
		return this.action; 
        }
	
	function getNodes() {
		
		return this.nodes; 
	}
	
	function loadRoute() {
		
		/*
		 * Create a route object and call the action method if exists.
		 */
		var routePath = "routes." & this.route;
		
		try { 
			var route = CreateObject("component", routePath).init();
			
			/*
			 * build a methodName string based on the method supplied. 
			 * check if action exists call the method
			 */
			
			var methodName = "action" & this.action;
					
			if(StructKeyExists(route, methodName)) {
				
				/* get the method reference */
				var method = route[methodName];
				
				/* call the method */
				method();  
			}
 
		} catch (any e) {
		
			/*
			 * create an error object and display
			 */
			writedump(e.message); 
		}
		
	}
}

</cfscript>