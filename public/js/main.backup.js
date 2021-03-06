
/*
Polyfill  methods
 */
Number.isInteger = Number.isInteger || function(value) {
    return typeof value === "number" &&
        isFinite(value) &&
        Math.floor(value) === value;
};

/********************************************************************************/



function renderQuestion(resp) {

    if(resp.statusCode == 200) {

        //extract all of the parts.
        var question = resp.data.question[0];
        var options = resp.data.options;
        var answer = resp.data.answer;

        //array of answer values.
        var answers = [];

        //create the form element.
        var html =  '<form id="form-question-data" method="post" action="/survey/submitAnswer">';
        html += '<input id="q_id" type="hidden" name="q_id" value="' + question.ENTITY_ID + '"/>';
        html += '<input id="q_type" type="hidden" name="q_type" value="' + question.TYPE.trim() + '"/>';
        html += '<input id="a_type" type="hidden" name="a_type" value="' + question.DATA_TYPE + '"/>';

        html += '<p id="p-question">' + resp.data.question[0].QUESTION + '</p>';

        var type = resp.data.question[0].TYPE.trim();

        if(type == 'radio' || type=='checkbox') {

            if (options && options.length && options.length > 0) {

                /*
                 if answer is not empty, create an array of values to check against.
                 */
                if(answer && answer.length && answer.length == 1) {
                    var list = answer[0].VALUE.trim().split('|');
                }

                /*loop and build the options list.
                the values property of the input field must replace all comma ',' characters
                with a '~' because coldfusion uses ',' as a list separator. Therefore
                leaving the comma in place would split an option into pieces.
                 */
                for (var i = 0; i < options.length; i++) {

                    var value = options[i].VALUE.trim()


                    html += "<input id='o_id-" + options[i].ENTITY_ID +
                    "' type='" + type.trim() +
                    "' name='answer'" +
                    "' value='" + options[i].VALUE.trim().replace(',','~') + "'";

                    /* check if the value exists in the options list. */
                    if(list && list.indexOf(value) != -1) {
                        html += " checked ";
                    }

                    html += "/>" + value + "<br />";

                }
            }
        } else if (type=='text') {

            /*check if answer is set for the current question and
            set the data inside the id field and the value.
             */
            html += "<textarea class='text' name='answer'>";
            if(answer && answer.length && answer.length > 0) {

                html += answer[0].VALUE;
            }

            html += "</textarea><br />";
        }

        html += "<button onclick='getQuestion(this)' " +
        "id='button-previous' type='button' name='submit' value='previous'>Prev</button>";

        /*
        html += "<button onclick='submitAnswer(this)' " +
        "id='button-submit' type='button' name='submit' value='submit'>Submit</button>";
        */

        html += "<button onclick='getQuestion(this)' " +
        "id='button-next' type='button' name='submit' value='next'>Next</button>";


        html += "<br />" +
        "<button onclick='getQuestion(this)' id='button-skip' " +
        "type='button' name='submit' value='skip'>Skip</button>";


        html += '</form>';

        document.getElementById('div-content').innerHTML = html;
    }

}

function getQuestion(e) {

    /* extract the value of the clicked button element */
    var action = e.getAttribute('value');

    /* if the action is next save the current question */
    if(action == 'next') {

        if(!submitAnswer()) { return; }
    }

    if(action =='skip') {
        var q = confirm("Are you Sure you want to skip?");

        if(!q) { return; }

        skipQuestion();
        //change the action to 'next' to load the next question
        action = 'next';
    }

    var url = 'load' + action;

    /* get the current question_id */
    var q_id = $("input#q_id").val();

    var settings = {
        url: '/survey/' + url,
        type: 'POST',
        data: 'q_id=' + q_id,
        dataType: 'json'
    };

    var callback = function(data) {

        if(data && data.statusCode) {
            switch(parseInt(data.statusCode)){
                case 200:
                    renderQuestion(data);
                    break;

                case 204:
                    finished(data);
                    break;

                case 400:
                    error(data);
                    break;
            }
        }
    }

    $.ajax(settings).done(callback);
}

function skipQuestion(e) {
    var q_id = $('input#q_id').val();

    var settings = {
        url: '/survey/skip',
        type: 'POST',
        data: 'q_id=' + q_id,
        dataType: 'json'
    };

    var callback = function(data) {

        if(data && data.statusCode) {

            if(data && data.statusCode) {

                switch(parseInt(data.statusCode)){
                    case 200:

                        break;

                    case 400:
                        error(data);
                        break;
                }
            }
        }
    }

    $.ajax(settings).done(callback);

}

function submitAnswer(ele){


    /* if the data is not valid return false */
    if(!isValid()) { return false; }

    //serialize the form.
    var data = $('form#form-question-data').serialize();

    var settings = {
        url: '/survey/save',
        type: 'POST',
        data: data,
        dataType: 'json'
    };

    var callback = function(data) {



        if(data && data.statusCode) {
            switch(parseInt(data.statusCode)){
                case 200:
                    message(data);
                    break;

                case 204:
                    finished(data);
                    break;

                case 400:
                    error(data);
                    break;
            }
        }
    }

    $.ajax(settings).done(callback);

    return true;
}

function isValid() {

    var valid = true;

    /* get the question type */
    var q_type = $('input#q_type').val();

    /*get the answer values */
    var answers = $("[name='answer']");

    /*based on q_type check if an answer has been selected. */
    if(q_type == 'radio' || q_type == 'checkbox') {

        /* if the question type is a radio or checkbox
         loop over all of the answer objects and make sure at least
         one item is checked.
         */
        var checked = false;

        var callback = function(index) {
            if($(this).is(':checked')) {
                checked = true;
            }
        }
        answers.each(callback);

        /* if the checked flag is false, no answers has been supplied,
         return false;
         */
        if(checked == false) {

            alert('Please Select an Answer, or Click Skip to skip the question');

            return false;
        }

    } else if(q_type == 'text') {
        /* if the answer is a text type, validate that the value of the
         textarea is not empty.
         */
        if($(answers[0]).val() == "") {

            alert('Please Enter an Answer or Select Skip to skip the question');

            return false;

        } else {
            /* get the answer type and validate the answer */
            var a_type = $('input#a_type').val();

            /* get the value */
            var value = $(answers[0]).val();

            /* validate that the answer is the correct data type */
            switch (a_type.trim().toLowerCase()) {
                case 'date':

                    /* try to convert the data into a unit timestamp */
                    if(isNaN(Date.parse(value))){
                        alert('Value Must be a valid date.');

                        return false;
                    }

                    break;

                case 'currency':

                    /* check that the value is a valid number */
                    if(isNaN(value)) {

                        alert('Value Must be a valid currency amount.');

                        return false;
                    } else {

                        /* if the value is a valid number, format the answer
                         and set it back into the field for when its serialized
                         */

                        $(answers[0]).val(Math.round(value * 100) / 100);
                    }

                    break;
                case 'int':

                    if(isNaN(value) || value % 1 != 0) {

                        alert('Value Must be a valid Integer.');

                        return false;
                    }
                    break;

                case 'float':
                    if(isNaN(value)) {

                        alert('Value Must be a valid Number.');

                        return false;
                    }
                    break
            }
        }
    }

    return true;
}

function logout() {
    var q = prompt("Confirm Logout");

    if(q) {
        /* ajax call to the logout action */
        console.log('logging out');
    }
}

function config() {

}

function login() {

}

function finished() {
    alert('survey finished');
}

function message(data) {
    console.log(data.message);
    $('p#p-message').text(data.message);
}

function error(data) {

}
$(document).ready(function() {
    $('button#button-start-survey').on('click', function(e){
        var settings = {
            url: '/survey/start',
            type: 'GET',
            data: '',
            dataType: 'json'
        };

        var callback = function(data) {
            renderQuestion(data);
        }

        $.ajax(settings).done(callback);
    });


    $('button#button-logout').on('click', logout);
})