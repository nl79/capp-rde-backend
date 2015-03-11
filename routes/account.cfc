<cfscript>

component Account
	output="false"
	extends="_base_route"
	{
         
        function actionIndex() {
	    //writedump('account-index'); 
	    /*
	     *if the index action is called.
	     *redirect to the login page.
	     */
	    
	    include "/public/index.html"; 
	    
	     
        
        }
        
        function actionDefault() {
            
        }
	
	/*
	 *@method: actionLogin() - queries the database and validates users
	 *survey code.
	 */ 
        
        function actionLogin() {

	    /* get the session object */
	    var sess = super.getSession();
	    
	    /* get the request object */
	    var req = super.getRequest();
	    
	    
	    //get the survey code. 
	    var s_code = req.getData('s_code'); 
	    
	    //get the terms of service status
	    var tos = req.getData('tos'); 
	    
            /*
	     *validate the users survey code
	     *and the Terms of service flag
	     */
	    if(len(s_code) > 0) {
		
		//query the database
		var q = new Query();
		
		q.setDatasource("rde_survey");
		q.setSQL('SELECT * FROM survey_code_table WHERE s_code= :s_code');
		q.addParam(name='s_code', value=s_code,CFSQLTYPE="CF_SQL_CHAR"); 
		result = q.execute().getResult(); 
		

		/*
		 *check if results were returned.
		 *extract the servey ID and store it in session.
		 */ 
		if(result.recordcount > 0) {
		     
		    /*
		     *store the logged in status in the session.
		     */
		    
		    sess.putValue('s_code_id', result['entity_id'][1]);
		    sess.putValue('s_code', result['s_code'][1]);
		    sess.putValue('s_id', result['s_id'][1]);
		    
		    //set the valid flag to true.
		    sess.putValue('valid', true); 
		    
		    
		    /* redirect to the survey index page */
		    location('/survey');
		    exit; 
		    
		} else {
		    
		    /*
		    *return a json object with an error message.
		    */
		    var msg = StructNew();
		   
		    msg.type  = "error";
		    msg.message = "Survey Code is Invalid";
		    msg.statusCode = 401;
		    
		    writeoutput(SerializeJSON(msg)); 
		    
		}
		    
	    } else {
		/*
		 *return a json object with an error message.
		 */
		var msg = StructNew();
		
		msg.type  = "error";
		msg.message = "Survey Code and Term of Service Acknowledgement Required";
		msg.statusCode = 401;
		
		writeoutput(SerializeJSON(msg)); 
	    }
        }
	
	function actionLogout() {
	    
	}
}

</cfscript>