<cfscript>

component Error
	output="false"
	extends="_base_route"
	{
        
	 
        
        Index function init() {
            
            return(this); 
        }
        
        function show() {
            writedump('ERROR OCCURED!!')
        }
        
        function toString() {
            writedump('ERROR OCCURED!!'); 
        }
}

</cfscript>