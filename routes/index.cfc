<cfscript>

component Index
	extends="_base_route"
	output="false"
	{
        
        function actionIndex() {
        
            writedump('here_index_index'); 
            
             
            //session.putValue('count', 1343); 
            writedump(super.getSession().getValue('count'));
        }
        
        function actionDefault() {
            session = GetPageContext().GetSession(); 
            writedump(session.getValue('count'));
            session.putValue('count', 987); 
        }
       
}

</cfscript>