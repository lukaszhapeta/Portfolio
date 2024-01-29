# Introduction

This project involves the analysis of the "Credit Card Fraud Detection" dataset, which can be downloaded from https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud/data.

The primary goal was to explore Docker, MySQL, and databases by extending the data analysis into creating a database within Docker's container, with connections through Python.

## Steps Taken:
1. **Data Analysis:**
	- Split the data into a train and test set. The test set was exported into `csv_files/transactions.csv` for later use.
	- Implemented a Logistic Regression model, testing with various thresholds.
	- Utilized a Random Forest model for further analysis.
2. **Database Creation:**
   	- Loaded `csv_files/transactions.csv` as the transaction table.
   	- Added tables for clients, cards, and predictions made with the Random Forest model.

	Above operations are stored in `sql_files/database.sql` file. Database ER diagram is presented in `sql_files/ER_diagram.png`.
3. **Python-Database Connection:**
	- Established a connection with the database at the Python level using a Docker container.
4. **Database Procedure:**
	-  The file `sql_files/procedure.sql` contains a procedure that utilizes every table in the database, offering a comprehensive overview of its structure and functionality.

I have provided clear comments in every cell to facilitate understanding of each step.

# How to run it?

To run the project, follow these sequential commands for building the Docker image and running the container:

1. **Build Docker Image:**
   ```bash
   docker build -t ccfd_image .
   ```
2. **Run Docker Container:**
   ```bash
   docker run -d -p 3308:3306 --name ccfd_project ccfd_image
   ```
The image is automatically configured to build the database using the `sql_files/database.sql` and `csv_files/transactions.csv` files.
