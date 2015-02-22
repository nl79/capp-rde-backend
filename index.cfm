<cfscript>
    This.sessionManagement="Yes";
    
    writedump(FORM);
    //session = GetPageContext().GetSession(); 

    objRequest = GetPageContext().GetRequest(); 
    strUrl = objRequest.GetRequestUrl(); 
    //writedump(strUrl.toString());
    
    /*
     *extract the path_info and remove the first '/' from the string
     */
    path = RemoveChars(cgi.PATH_INFO, 1, 1);
    
    /*
     *split the string on '/' into nodes. 
     */
    nodes = path.split('/');
    
    //If the path_info and script name are the same, the user requested the root file.
    if(compare(cgi.PATH_INFO, cgi.SCRIPT_NAME) == 0) {
        nodes = [];
        
        /*
         *append a default route: survey
         *Action: login
         */
        ArrayAppend(nodes, 'survey');
        ArrayAppend(nodes, 'login'); 
        
    }
    
    /*
     *Parse the request URI and load the appropriate
     *Route.
     */
    router = new components.Router(nodes);
    
    router.loadRoute();  
    exit;
    
    
    
    
	queryService = new Query(); 
	
	queryService.setDatasource("rde_survey");
	queryService.setSQL('select * from question_table');
	result = queryService.execute();
        
        //writedump(serializeJson(result.getResult()));
        writedump(result.getResult()); 
	/*
	yQry = new Query(); // new query object     
	    myQry.setSQL("select bookid, title, genre from app.books where bookid = :bookid"); //set query
	    myQry.addParam(name="bookid",value="5",CFSQLTYPE="CF_SQL_INT"); // add query param
	    qryRes = myQry.execute(); // execute query
	    writedump(qryRes.getResult().recordcount, true); // get resultcount
	    writedump(qryRes.getResult(), false); // dump result
	*/
	
    writedump(cgi);
    

</cfscript> 