USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER 

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa]

USE WideWorldImporters


--Занос данных

CREATE TABLE My_schema.CountInv(
[CustomerID] [int] NOT NULL,
[DateBegin] [date] NULL,
[DateEnd] [date] NULL,
[InvoicesCount] [int] NOT NULL,
[ReportDate] [datetime])


--MessageType

CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO

CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );
GO

--Queue

CREATE QUEUE TargetQueueWWI;

CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);
GO


CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);
GO


--SP_SendMessage

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE My_Schema.SendCustomer
	@CustomerID INT,
	@DataStart as date,
	@DataEnd as date

AS
BEGIN
	--SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
		
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT DISTINCT  @CustomerID as CustomerID,
								     @DataStart as DataStart ,
								     @DataEnd as DataEnd
							  FROM  Sales.Invoices AS Inv
							  WHERE CustomerID = @CustomerID
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 


	

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage;
	 
	
	COMMIT TRAN 
END
GO

--SP_ReplyMessage

CREATE OR ALTER PROCEDURE My_Schema.GetCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerID INT,
			@DataStart DATE,
			@DataEnd DATE,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM [dbo].[TargetQueueWWI];

	

	SET @xml = CAST(@Message AS XML);

	SELECT @CustomerID = R.Cus.value('@CustomerID','INT'),
			@DataStart = R.Cus.value('@DataStart','date'),
			@DataEnd = R.Cus.value('@DataEnd','date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Cus);

	
	IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerID = @CustomerID)
	BEGIN
		
	
	INSERT INTO My_schema.CountInv 
				([CustomerID]
			  ,[DateBegin]
			  ,[DateEnd]
			  ,[InvoicesCount]
			  ,[ReportDate])
		SELECT @CustomerID,
		@DataStart,
		@DataEnd,
		COUNT(*),
		GETDATE()
		FROM [Sales].[Invoices]
		WHERE [CustomerID]=@CustomerID and  [InvoiceDate] BETWEEN @DataStart AND @DataEnd and @CustomerID is not null
		GROUP BY [CustomerID]
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --íå äëÿ ïðîäà
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);

		END CONVERSATION @TargetDlgHandle;
	END 
	

	COMMIT TRAN;
END

GO

CREATE OR ALTER PROCEDURE My_schema.ConfirmCustomer
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 

			
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		
		--SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --íå äëÿ ïðîäà
		--insert into My_schema.ConfirmCustomerLog select getdate(),@ReplyReceivedMessage

	COMMIT TRAN; 
END

GO


--AlterQueue

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = My_schema.ConfirmCustomer, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = My_Schema.GetCustomer, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO


EXEC [MY_schema].[SendCustomer] 76,'2013-01-01','2014-05-31'
SELECT * FROM [MY_schema].[CountInv]

SELECT * FROM sys.service_contract_message_usages; 
SELECT * FROM sys.service_contract_usages;
SELECT * FROM sys.service_queue_usages;
 
SELECT * FROM sys.transmission_queue;

SELECT * 
FROM dbo.InitiatorQueueWWI;

SELECT * 
FROM dbo.TargetQueueWWI;

select name, is_broker_enabled
from sys.databases;

SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;