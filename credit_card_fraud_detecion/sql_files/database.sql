# Database creation
CREATE OR REPLACE DATABASE card_fraud; 

USE card_fraud;

# Creating the skeleton of the 'transactions' table
CREATE OR REPLACE TABLE transactions (
	`Time` INT,
	V1 FLOAT,
	V2 FLOAT,
	V3 FLOAT,
	V4 FLOAT,
	V5 FLOAT,
	V6 FLOAT,
	V7 FLOAT,
	V8 FLOAT,
	V9 FLOAT,
	V10 FLOAT,
	V11 FLOAT,
	V12 FLOAT,
	V13 FLOAT,
	V14 FLOAT,
	V15 FLOAT,
	V16 FLOAT,
	V17 FLOAT,
	V18 FLOAT,
	V19 FLOAT,
	V20 FLOAT,
	V21 FLOAT,
	V22 FLOAT,
	V23 FLOAT,
	V24 FLOAT,
	V25 FLOAT,
	V26 FLOAT,
	V27 FLOAT,
	V28 FLOAT,
	Amount FLOAT,
	Class BOOLEAN
);

# Loading data into the above table
LOAD DATA INFILE '/docker-entrypoint-initdb.d/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Creating a duplicate of the 'transactions' table that will contain all essential information
CREATE OR REPLACE TABLE transactions_details AS SELECT * FROM transactions WHERE 1=1;

# Adding a column 'id' to the table with transaction details, setting it as the primary key
ALTER TABLE transactions_details ADD COLUMN id INT PRIMARY KEY AUTO_INCREMENT FIRST;

# Adding a column 'id' to the 'transactions' table, setting it as a foreign key
ALTER TABLE transactions
ADD COLUMN id INT FIRST,
ADD CONSTRAINT fk_transactions_id
FOREIGN KEY (id) REFERENCES transactions_details(id);

# Appending the 'id' to each row in the 'transactions' table, using the default order
SET @row_number = 0;

UPDATE transactions
SET id = (SELECT @row_number := @row_number + 1);

# The following procedure deletes all columns except for 'id' in the 'transactions' table
DELIMITER //
CREATE OR REPLACE PROCEDURE card_fraud.DropColumnsDynamically()
BEGIN
  DECLARE column_to_drop VARCHAR(255);
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_columns CURSOR FOR
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'card_fraud'
      AND TABLE_NAME = 'transactions'
      AND (ORDINAL_POSITION BETWEEN 2 AND 33);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur_columns;
  read_loop: LOOP
    FETCH cur_columns INTO column_to_drop;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET @alter_table_query = CONCAT('ALTER TABLE card_fraud.transactions DROP COLUMN ', column_to_drop);
    PREPARE stmt FROM @alter_table_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;
  CLOSE cur_columns;
END //
DELIMITER ;

# Calling the procedure
CALL DropColumnsDynamically();

# Creating a table for clients
CREATE OR REPLACE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    second_name VARCHAR(50),
    phone_number VARCHAR(20),
    city VARCHAR(50),
    street VARCHAR(50),
    house_number INT,
    postal_code VARCHAR(10),
    creation_date DATE,
    pesel VARCHAR(11),
    mother_maiden_name VARCHAR(50)
);

# Procedure for generating PESEL (Personal Identification Number)
DELIMITER //
CREATE OR REPLACE PROCEDURE GeneratePesel(OUT pesel_param VARCHAR(11))
BEGIN
    DECLARE birth_year INT;
    DECLARE birth_month INT;
    DECLARE birth_day INT;
    DECLARE random_year INT;
    DECLARE random_month INT;
    DECLARE random_day INT;

    SET birth_year = FLOOR(RAND() * (2000 - 1950 + 1) + 1950);
    SET birth_month = LPAD(FLOOR(RAND() * 12) + 1, 2, '0');
    SET birth_day = LPAD(FLOOR(RAND() * 28) + 1, 2, '0');

    SET random_year = FLOOR(RAND() * (YEAR(CURDATE()) - birth_year + 1) + birth_year);
    SET random_month = FLOOR(RAND() * 12) + 1;
    SET random_day = FLOOR(RAND() * 28) + 1;

    SET pesel_param = CONCAT(SUBSTRING(random_year, 3, 2), LPAD(random_month, 2, '0'), LPAD(random_day, 2, '0'), LPAD(FLOOR(RAND() * 9999) + 1, 4, '0'));
END;

# Trigger automatically generating PESEL during record insertion
CREATE OR REPLACE TRIGGER BeforeInsert
BEFORE INSERT ON clients
FOR EACH ROW
BEGIN
    DECLARE pesel_old VARCHAR(11);
    CALL GeneratePesel(pesel_old);
    SET NEW.pesel = pesel_old;
END //
DELIMITER ;

# Populating the 'clients' table
INSERT INTO clients (first_name, second_name, phone_number, city, street, house_number, postal_code, creation_date, mother_maiden_name)
VALUES
    ('Michał', 'Kowalski', '123-456-7890', 'Warszawa', 'Aleje Jerozolimskie', 23, '00-001', '2022-01-01', 'Nowak'),
    ('Anna', 'Nowak', '987-654-3210', 'Kraków', 'Floriańska', 45, '30-001', '2022-01-02', 'Kowalczyk'),
    ('Piotr', 'Wiśniewski', '555-123-4567', 'Wrocław', 'Świdnicka', 67, '50-001', '2022-01-03', 'Lis'),
    ('Katarzyna', 'Dąbrowska', '777-888-9999', 'Gdańsk', 'Długa', 89, '80-001', '2022-01-04', 'Kowal'),
    ('Rafał', 'Lewandowski', '333-444-5555', 'Poznań', 'Wielka', 101, '60-001', '2022-01-05', 'Jaworski'),
    ('Alicja', 'Zielińska', '222-333-4444', 'Łódź', 'Piotrkowska', 123, '90-001', '2022-01-06', 'Szymańska'),
    ('Marek', 'Szymański', '111-222-3333', 'Szczecin', 'Monte Cassino', 145, '70-001', '2022-01-07', 'Kaczmarek'),
    ('Natalia', 'Jankowska', '999-888-7777', 'Bydgoszcz', 'Gdańska', 167, '85-001', '2022-01-08', 'Woźniak'),
    ('Kamil', 'Wojciechowski', '666-555-4444', 'Katowice', 'Mariacka', 189, '40-001', '2022-01-09', 'Witkowski'),
    ('Karolina', 'Kaczmarek', '444-333-2222', 'Białystok', 'Lipowa', 211, '15-001', '2022-01-10', 'Zając'),
    ('Artur', 'Zając', '777-999-1111', 'Gdynia', 'Starowiejska', 233, '81-001', '2022-01-11', 'Grabowska'),
    ('Joanna', 'Grabowska', '555-666-7777', 'Częstochowa', 'Brzeźnicka', 255, '42-001', '2022-01-12', 'Kubiak'),
    ('Krzysztof', 'Kowalczyk', '888-777-6666', 'Lublin', 'Krakowskie Przedmieście', 277, '20-001', '2022-01-13', 'Nowicki'),
    ('Monika', 'Nowicka', '222-444-8888', 'Radom', 'Waryńskiego', 299, '26-001', '2022-01-14', 'Szczepańska'),
    ('Adam', 'Szczepański', '111-999-5555', 'Olsztyn', 'Kościuszki', 321, '10-001', '2022-01-15', 'Pawlak');

# Creating a table for clients' cards
CREATE OR REPLACE TABLE cards (
	id INT AUTO_INCREMENT PRIMARY KEY,
	owner_id INT,
	card_number BIGINT,
	expiration_date DATE,
	CVV INT,
	FOREIGN KEY (owner_id) REFERENCES clients(id)
);

# Trigger automatically generating card number, expiration date and CVV during record insertion
DELIMITER //
CREATE OR REPLACE TRIGGER generate_card_data
BEFORE INSERT ON cards
FOR EACH ROW
BEGIN
    -- Generating card_number - a sequence of 16 randomly generated digits
    SET NEW.card_number = LPAD(FLOOR(RAND() * 10000000000000000), 16, '0');

    -- Generating expiration_date - a date up to 3 years in the future from the current date
    SET NEW.expiration_date = DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 3) + 1 YEAR);

    -- Generating CVV - a sequence of 3 randomly generated digits
    SET NEW.CVV = LPAD(FLOOR(RAND() * 1000), 3, '0');
END //
DELIMITER ;

# Populating the cards table
INSERT INTO cards (owner_id)
VALUES
    (1), (2), (3), (4), (5),
    (6), (7), (8), (9), (10),
    (11), (12), (13), (14), (15);

# Adding the 'id_card' column to the 'transactions' table
ALTER TABLE transactions
ADD COLUMN card_id INT;

# Assigning an 'id_card' to each column in the 'transactions' table
UPDATE transactions
SET card_id = FLOOR(RAND() * 15) + 1;

# Adding a relationship between the 'cards' and 'transactions' tables
ALTER TABLE transactions
ADD FOREIGN KEY (card_id) REFERENCES cards(id);

# Creating a table for potential frauds
CREATE OR REPLACE TABLE predicted_fraud (
	id INT,
	prediction VARCHAR(15),
	FOREIGN KEY (id) REFERENCES transactions(id)
);

# Creating a table for transactions that are not frauds 
CREATE OR REPLACE TABLE predicted_not_fraud (
	id INT,
	prediction VARCHAR(15),
	FOREIGN KEY (id) REFERENCES transactions(id)
);

# Determining predictions for each transaction through a trigger
DELIMITER //
CREATE OR REPLACE TRIGGER prediction_not_fraud
BEFORE INSERT ON predicted_not_fraud
FOR EACH ROW
BEGIN
    SET NEW.prediction = "Not fraud";
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE TRIGGER prediction_fraud
BEFORE INSERT ON predicted_fraud
FOR EACH ROW
BEGIN
    SET NEW.prediction = "Fraud";
END //
DELIMITER ;
