-- Drop database rde_survey; 
-- CREATE database rde_survey; 

drop table user_table; 
CREATE TABLE user_table(
entity_id	int		not null	PRIMARY KEY, 

); 

DROP TABLE question_table; 
CREATE TABLE question_table(
	entity_id	int	not null	PRIMARY KEY, 
	question	text	not null, 
	q_type		enum('multi', 'single')	not null, 	-- controls if the questions are radio buttons or checkboxes
	
	
); 
