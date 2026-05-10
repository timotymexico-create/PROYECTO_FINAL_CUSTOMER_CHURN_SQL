---INICIO DE PROYECCTO
---CARGA MASIVA

CREATE TABLE Telco_Customer_Churn(
	customerID  NVARCHAR (50),
	gender  NVARCHAR (50),
	SeniorCitizen  NVARCHAR (50),
	Partner  NVARCHAR (50),
	Dependents  NVARCHAR (50),
	tenure  NVARCHAR (50),
	PhoneService  NVARCHAR (50),
	MultipleLines  NVARCHAR (50),
	InternetService  NVARCHAR (50),
	OnlineSecurity  NVARCHAR (50),
	OnlineBackup  NVARCHAR (50),
	DeviceProtection  NVARCHAR (50),
	TechSupport  NVARCHAR (50),
	StreamingTV  NVARCHAR (50),
	StreamingMovies  NVARCHAR (50),
	Contract  NVARCHAR (50),
	PaperlessBilling  NVARCHAR (50),
	PaymentMethod  NVARCHAR (50),
	MonthlyCharges  NVARCHAR (50),
	TotalCharges  NVARCHAR (50),
	Churn  NVARCHAR (50),

)

SELECT*
FROM Telco_Customer_Churn

BULK INSERT Telco_Customer_Churn
FROM 'C:\Users\HP\OneDrive\Documentos\SQL Server Management Studio\PROYECTO SQL\DATA\WA_Fn-UseC_-Telco-Customer-Churn.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);

SELECT*
FROM Telco_Customer_Churn
