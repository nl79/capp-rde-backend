<cfscript>

component Error
	output="false"
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