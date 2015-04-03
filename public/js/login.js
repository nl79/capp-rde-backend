
/*
Polyfill  methods
 */
Number.isInteger = Number.isInteger || function(value) {
    return typeof value === "number" &&
        isFinite(value) &&
        Math.floor(value) === value;
};

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}



/********************************************************************************/

function config() {
    /* prompt the user for the ip address */
    var ip = prompt("Enter Server's IP Address(xxx.xxx.xxxx.xxxx)");

    $('input#input-ip').val(ip);

    var tempStorage = window.sessionStorage;
    tempStorage.ip = ip;

    return true;
}


function accountLogin() {
	/* get the hidden ip field */

    var ip = window.sessionStorage.ip;

    if(!ip || ip == 'null') {
        if(!config()) { return false; }
    }

    var ip = $('input#input-ip').val();

    var data = $('form#form-login').serialize();

    var url = 'http://' + ip + '/account/login';

    var settings = {
        url: url,
        type: 'POST',
        data: data,
        dataType: 'json'
    };

    var callback = function(data, status, xhr) {

        if(data && data.statusCode) {

            switch(parseInt(data.statusCode)){

                case 302:

                    /* get the session id and set it as cookie */
                    //var JSESSIONID = data.JSESSIONID;

                    //if(JSESSIONID) { setCookie('JSESSIONID', JSESSIONID, -1)}

                    //var tempStorage = window.sessionStorage;
                    //tempStorage.JSESSIONID = JSESSIONID;

                    /* redirect */
                    var url = data.url.trim();


                    window.location = url;

                    break;

                default:

                    message(data.message);
                    break;

            }
        }
    }

    $.ajax(settings).done(callback);
}

function finished() {
    alert('survey finished');
}

function message(msg) {

    $('p#p-message').text(msg);
}
