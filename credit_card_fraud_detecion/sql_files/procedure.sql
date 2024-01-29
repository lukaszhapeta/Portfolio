# Procedure displaying the first name, last name, phone number of the client, along with the transaction amount and prediction.
# Fraudulent transactions are displayed first. 
USE card_fraud;

CREATE OR REPLACE PROCEDURE TransactionInfo(IN transaction_id INT)
BEGIN
	IF transaction_id IS NOT NULL THEN
		SELECT c2.first_name, c2.second_name, c2.phone_number, td.Amount, prd.prediction FROM (SELECT * FROM predicted_fraud UNION SELECT * FROM predicted_not_fraud) AS prd
		INNER JOIN transactions t ON t.id = prd.id
		INNER JOIN transactions_details td ON td.id = prd.id
		INNER JOIN cards c ON c.id = t.card_id 
		INNER JOIN clients c2 ON c2.id = c.owner_id
		WHERE transaction_id = t.id
		ORDER BY prd.prediction;
	ELSE 
		SELECT c2.first_name, c2.second_name, c2.phone_number, td.Amount, prd.prediction FROM (SELECT * FROM predicted_fraud
		UNION SELECT * FROM predicted_not_fraud) AS prd
		INNER JOIN transactions t ON t.id = prd.id
		INNER JOIN transactions_details td ON td.id = prd.id
		INNER JOIN cards c ON c.id = t.card_id 
		INNER JOIN clients c2 ON c2.id = c.owner_id
		ORDER BY prd.prediction;
	END IF;
END;

# Calling the transaction. Using a NULL value will display all rows in the table. Providing a number will display a specific row with the given ID.
CALL TransactionInfo(NULL);

# During the running Python code, we can check the increasing number of transactions "live."
SELECT count(*) FROM (SELECT * FROM predicted_fraud pf UNION SELECT * FROM predicted_not_fraud pnf) prd;