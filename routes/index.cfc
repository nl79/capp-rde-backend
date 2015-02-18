<cfscript>

component Index
	output="false"
	{
        
	 
        
        Index function init() {
            
            return(this); 
        }
        
        function actionIndex() {
        
            writedump('here'); 
            
            session = GetPageContext().GetSession(); 
            //session.putValue('count', 1343); 
            writedump(session.getValue('count'));
        }
        
        function actionDefault() {
            session = GetPageContext().GetSession(); 
            writedump(session.getValue('count'));
            session.putValue('count', 987); 
        }
       
}

</cfscript>