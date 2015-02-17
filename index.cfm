<cfoutput>#ucase("hello world")#</cfoutput>

<cfscript>
    var = 'hello'; 
    writedump('hello');
    writedump(getMetadata(var).getName());
    
    if(true) {
    writedump('true'); 
    }
    
    writedump(cgi); 

</cfscript> 