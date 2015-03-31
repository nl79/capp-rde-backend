
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
        html += '<input type="hidden" name="q_id" value="' + question.ENTITY_ID + '"/>';
        html += '<input type="hidden" name="q_type" value="' + question.TYPE.trim() + '"/>';
        html += '<input type="hidden" name="a_type" value="' + question.A_TYPE + '"/>';

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
                    if(list.indexOf(value) != -1) {
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

                html += answer[0].VALUE.trim();
            }

            html += "</textarea><br />";
        }

        html += "<button onclick='getPrevious(this)' " +
        "id='button-previous' type='button' name='submit' value='previous'>Prev</button>";

        html += "<button onclick='submitAnswer(this)' " +
        "id='button-submit' type='button' name='submit' value='submit'>Submit</button>";

        html += "<button onclick='getNext(this)' " +
        "id='button-next' type='button' name='submit' value='next'>Next</button>";


        html += "<br />" +
        "<button onclick='skip(this)' id='button-skip' " +
        "type='button' name='submit' value='skip'>Skip</button>";


        html += '</form>';

        document.getElementById('div-content').innerHTML = html;
    }

}

function getNext() {
    alert('next');
}

function getPrevious() {
    alert('previous');
}

function skip() {
    alert('skip');
}

function submitAnswer(ele){

    //serialize the form.
    var data = $('form#form-question-data').serialize();

    var settings = {
        url: '/survey/save',
        type: 'POST',
        data: data,
        dataType: 'json'
    };

    var callback = function(data) {
        console.log(data);
    }

    $.ajax(settings).done(callback);

}

$(document).ready(function() {
    $('button#button-start-survey').on('click', function(e){
        var settings = {
            url: '/survey/loadLast',
            type: 'GET',
            data: '',
            dataType: 'json'
        };

        var callback = function(data) {
            renderQuestion(data);
        }

        $.ajax(settings).done(callback);

    })
})