<cfscript>

component Router
	output="false"
	{
        
        property string route;
        property string action; 
        
        Router function init(rt, ac) {
            this.route = rt;
            this.action = ac; 
        
            return(this); 
        }
        
        function getRoute() {
            return this.route; 
        }
        
        function getAction() {
            return this.action; 
        }
}

</cfscript>