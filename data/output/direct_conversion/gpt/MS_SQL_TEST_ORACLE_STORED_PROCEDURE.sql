CREATE PROCEDURE ORDDATA.Employee
AS
BEGIN
    -- There is no EXECUTE IMMEDIATE equivalent in SQL Server; dynamic SQL execution uses sp_executesql or EXEC.
    -- Creating tables dynamically
    EXEC sp_executesql N'CREATE TABLE ORDDATA.EMPLOYEE_DETAIL(
        EMPLOYEE_ID VARCHAR(50) NOT NULL,
        EMPLOYEE_FIRST_NAME VARCHAR(50) NOT NULL,
        EMPLOYEE_LAST_NAME VARCHAR(50) NOT NULL,
        CONSTRAINT PK_EMPLOYEE_DETAIL PRIMARY KEY (EMPLOYEE_ID)
    )';
 
    EXEC sp_executesql N'CREATE TABLE ORDDATA.Designation(
        EMPLOYEE_ID INT,
        EMPLOYEE_DESIGNATION VARCHAR(50) NOT NULL,
        CONSTRAINT PK_Designation PRIMARY KEY (EMPLOYEE_ID)
    )';
 
    -- Insert data into tables
    EXEC sp_executesql N'INSERT INTO ORDDATA.EMPLOYEE_DETAIL (EMPLOYEE_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME) VALUES (''01'', ''Uday'', ''Hegde'')';
    EXEC sp_executesql N'INSERT INTO ORDDATA.EMPLOYEE_DETAIL (EMPLOYEE_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME) VALUES (''02'', ''Lalit'', ''Bakshi'')';
    EXEC sp_executesql N'INSERT INTO ORDDATA.EMPLOYEE_DETAIL (EMPLOYEE_ID, EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME) VALUES (''03'', ''Shridhar'', ''Bhatt'')';
 
    EXEC sp_executesql N'INSERT INTO ORDDATA.Designation (EMPLOYEE_ID, EMPLOYEE_DESIGNATION) VALUES (01, ''CEO'')';
    EXEC sp_executesql N'INSERT INTO ORDDATA.Designation (EMPLOYEE_ID, EMPLOYEE_DESIGNATION) VALUES (02, ''PRESIDENT'')';
    EXEC sp_executesql N'INSERT INTO ORDDATA.Designation (EMPLOYEE_ID, EMPLOYEE_DESIGNATION) VALUES (03, ''SVP-HR'')';
 
    -- SQL Server doesn't support CREATE TABLE AS SELECT syntax; instead, use SELECT INTO.
    EXEC sp_executesql N'SELECT a.EMPLOYEE_ID
                              ,a.EMPLOYEE_FIRST_NAME
                              ,a.EMPLOYEE_LAST_NAME
                              ,EMPLOYEE_DESIGNATION
                       INTO ORDDATA.Organization
                       FROM ORDDATA.EMPLOYEE_DETAIL a
                       JOIN ORDDATA.Designation b ON a.EMPLOYEE_ID = b.EMPLOYEE_ID';
 
    -- SQL Server commits transactions implicitly; but for clarity or control, you can add explicit COMMIT statements.
    COMMIT;
 
    -- SQL Server doesn't have DBMS_OUTPUT, use PRINT instead for debug messages
    PRINT 'Tables created, data loaded, and joined successfully.';
END;
GO
 
-- SQL Server uses TRY...CATCH for error handling, but control structures cannot span batch separators (GO statements).
BEGIN TRY
    EXEC ORDDATA.Employee;
END TRY
BEGIN CATCH
    -- Rollback transaction if there's an error
    ROLLBACK;
    -- Output error message
    PRINT 'Error: ' + ERROR_MESSAGE();
    -- Re-raise if needed
    THROW;
END CATCH;