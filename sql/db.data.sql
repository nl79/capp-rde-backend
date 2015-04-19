/*
select *
  from information_schema.columns
 where table_name = 'survey_question_table';
*/

Drop database rde_survey;
CREATE database rde_survey;
USE rde_survey;

CREATE TABLE question_type (
	entity_id	int		not null	IDENTITY(1,1)	PRIMARY KEY,
	[type]		char(10)	not null
);

-- type of the answer permitted. EX: int, float, string.
CREATE TABLE answer_type (
	entity_id		int	not null IDENTITY(1,1)	PRIMARY KEY,
	[type]			char(15)	not null,
);

-- Survey table
CREATE TABLE survey_table(
	entity_id		int	        not null IDENTITY(1,1)	PRIMARY KEY,
	name			char(50)	not null,
	[description]	char(150)	null
);

-- Survey code table: stores the survey code and associted survey id.
CREATE TABLE survey_code_table(
    entity_id       int             not null	IDENTITY(1,1) PRIMARY KEY,
    s_code			char(8)			not null,
    s_id            int             not null        FOREIGN KEY REFERENCES survey_table(entity_id),
    tos             int             null,		-- a flag that records if terms of service was accepted.
    [last]          int             not null        default 0   --the last question in the list the user answered.
);

CREATE TABLE question_table(
	entity_id	int				not null	IDENTITY(1,1)	PRIMARY KEY,
	question	text			not null,
	q_type		int				not null    FOREIGN KEY REFERENCES question_type(entity_id),	-- controls if the questions are radio buttons or checkboxes
	-- options		char(150)	    null,	-- Answers options, delimited by the '|' simbol.
	a_type		int				null        FOREIGN KEY REFERENCES answer_type(entity_id),
);

CREATE TABLE option_table (
    entity_id       int     not null     IDENTITY(1,1)	PRIMARY KEY,
    [value]         char(150)   not null,
);

-- q_id - question id that the answer is assocciated with.
-- s_code_id - the survey code id the answer is assoccited with. (used for assocciting answer with individual takers).
CREATE TABLE answer_table(
	entity_id	int					not null		IDENTITY(1,1)	PRIMARY KEY,
	q_id		int					not null		FOREIGN KEY REFERENCES question_table(entity_id),
    s_code_id   int					not null        FOREIGN KEY REFERENCES survey_code_table(entity_id),
	value		varchar(255)		null
);

CREATE TABLE survey_question_table(
	s_id		int     not null FOREIGN KEY REFERENCES survey_table(entity_id),
	q_id		int		not null FOREIGN KEY REFERENCES question_table(entity_id),
);



CREATE TABLE question_options_table(
    q_id                int         not null        FOREIGN KEY REFERENCES question_table(entity_id),
    o_id                int         not null        FOREIGN KEY REFERENCES option_table(entity_id),

);

-- Test Data
-- Default question types
-- checkbox - multiple answers permitted.
-- radio - one answer selection permitted.
-- text - open ended answer.
INSERT INTO question_type ([type])
VALUES('checkbox'), ('radio'), ('text'), ('date'),('bigtext');

-- Default answer types
-- int - numeric value
-- float - floating point value
-- string - string value.
-- date - string in a date format.
INSERT INTO answer_type ([type])
VALUES('int'), ('float'), ('string'), ('date'), ('currency');

-- Test Survey
INSERT INTO survey_table (name, [description])
VALUES ('RDE App Survey', 'RDE-Test Survey');

-- Test Questions
INSERT INTO question_table(question, q_type, a_type)
VALUES('I identify myself as?', 2, 3),
('What is your age?', 2, 3),
('Ethnicity origin (or Race): Please specify your ethnicity', 2,3), 
('Which mobile device are you taking using this application on?', 2, 3), 
('Would you say our application color scheme is appealing?', 2, 3), 
('If you could choose a color scheme what would it be?', 3, 3), 
('Would you use this application again?',2,3), 
('How would you describe this application in one or more words?', 5, 3), 
('If you were to review this application what score would you give out of ten? 1 being the lowest.', 2,3), 
('What do you find most frustrating about this application?', 5,3), 
('What do you like best about this application?',5,3); 

-- QUESTIONS 1 OPTIONS
INSERT INTO option_table([value])
VALUES('Male'), ('Female'), ('Other');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(1,1),(1,2),(1,3);

-- QUESTIONS 2 OPTIONS
INSERT INTO option_table([value])
VALUES('Under 18 Years old'), ('18-24 Years Old'), ('25-34 Years Old'), ('35-44 Years Old'),('45-54 Years Old'), 
('55-64 Years Old'),('65-74 Years Old'),('75 Years or Older'); 
-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,10); 

-- QUESTION 3 OPTIONS
INSERT INTO option_table([value])
VALUES( 'White'),('Hispanic or Latino'),('Black or African American'),('Native American or American Indian'), 
('Asian / Pacific Islander'),('Other');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(3,11),(3,12),(3,13),(3,14);

-- QUESTION 4 OPTIONS
INSERT INTO option_table([value])
VALUES( 'Android'),('iOS'),('Windows');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(4,15),(4,16),(4,17); 

-- QUESTION 5 OPTIONS
INSERT INTO option_table([value])
VALUES( 'Very unappealing'),('Somewhat unappealing'),('Average'),('Somewhat appealing'),
('Very appealing'),('Other');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(5,18),(5,19),(5,20),(5,21),(5,22),(5,23);  

-- QUESTION 6 OPTIONS (Text)


-- QUESTION 7 OPTIONS
INSERT INTO option_table([value])
VALUES( 'Yes'),('No');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(7,24),(7,25); 


-- QUESTION 8 OPTIONS
INSERT INTO option_table([value])
VALUES( '1'),('2'),( '3'),('4'),( '5'),('6'),( '7'),('8'),( '9'),('10');

-- link options to the question
INSERT INTO question_options_table(q_id, o_id)
VALUES(8,26),(8,27), (8,28),(8,29),(8,30),(8,31),(8,32),(8,33),(8,34),(8,35); 

-- QUESTION 9 OPTIONS

-- QUESTION 10 OPTIONS

-- Link the questions to the survey.
INSERT INTO survey_question_table (s_id, q_id)
VALUES(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9);

-- Survey code table link - the survey code will be generated automatically.
INSERT INTO survey_code_table (s_code, s_id, tos)
VALUES('testsurv', 1, null),('testsur2', 1, null); 
