<cfscript>

    objRequest = GetPageContext().GetRequest(); 
    strUrl = objRequest.GetRequestUrl(); 
    
    writedump(strUrl.toString()); 

    var = 'hello'; 
    writedump('hello');
    writedump(getMetadata(var).getName());
    
	queryService = new Query(); 
	
	queryService.setDatasource("rde_survey");
	queryService.setSQL('select * from user_table');
	result = queryService.execute(); 
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