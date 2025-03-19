-- This script creates the roles and users needed by the RCM

USE master;
GO
--- create database
DECLARE @V_DB_EXIST_CHECK INT;
SELECT @V_DB_EXIST_CHECK = COUNT(*)
FROM dbo.sysdatabases
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE')));
IF @V_DB_EXIST_CHECK = 0 
BEGIN
 EXEC ('CREATE DATABASE ACTONE COLLATE SQL_Latin1_General_CP1_CI_AS')
END
GO
---------------- USER -----------------------
--- create login
DECLARE @V_LOGIN_EXIST INT;
SELECT @V_LOGIN_EXIST = COUNT(*)
FROM dbo.syslogins
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE_USER')));
IF @V_LOGIN_EXIST = 0 
BEGIN
 EXEC ('CREATE LOGIN ACTONE_USER WITH PASSWORD  = ''P@ssw0rd''')
END
GO

--- create user for login
USE ACTONE;

DECLARE @USER_EXIST_CHECK INT;
SELECT @USER_EXIST_CHECK = COUNT(*)
FROM dbo.sysusers
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE_USER')));   
IF @USER_EXIST_CHECK = 0
BEGIN
     EXEC ('CREATE USER ACTONE_USER FOR LOGIN ACTONE_USER');
END
GO
EXEC sp_addrolemember 'db_owner', 'ACTONE_USER'
GO

USE msdb;
GO

DECLARE @USER_EXIST_CHECK INT;
SELECT @USER_EXIST_CHECK = COUNT(*)
FROM dbo.sysusers
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE_USER')));

IF @USER_EXIST_CHECK = 0
BEGIN
     EXEC ('CREATE USER ACTONE_USER FOR LOGIN ACTONE_USER');
END
GO

GRANT SELECT on OBJECT::dbo.syscategories to [ACTONE_USER]
GO

GRANT SELECT on OBJECT::dbo.sysjobs to [ACTONE_USER]
GO

EXEC sp_addrolemember 'SQLAgentUserRole', 'ACTONE_USER'
GO

USE ACTONE;
---------------- APPLICATION USER -----------------------

USE master;

--- create login
DECLARE @V_LOGIN_EXIST INT;
SELECT @V_LOGIN_EXIST = COUNT(*)
FROM dbo.syslogins
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE_APP_USER')));
IF @V_LOGIN_EXIST = 0 
BEGIN
 EXEC ('CREATE LOGIN ACTONE_APP_USER WITH PASSWORD  = ''P@ssw0rd''')
END
GO

--- create application user for login
USE ACTONE;

DECLARE @USER_EXIST_CHECK INT;
SELECT @USER_EXIST_CHECK = COUNT(*)
FROM dbo.sysusers
WHERE NAME = LTRIM(RTRIM(UPPER('ACTONE_APP_USER')));   
IF @USER_EXIST_CHECK = 0
BEGIN
     EXEC ('CREATE USER ACTONE_APP_USER FOR LOGIN ACTONE_APP_USER');
END
GO
EXEC ('ALTER DATABASE ACTONE SET RECOVERY SIMPLE')
GO
----- APP ROLES ----
IF (select top 1 name from sys.database_principals where name = 'ACTONE_APP_USER' and type = 'R') IS NULL
 EXEC sp_addrole ACTONE_APP_USER
GO

----------------- Grant object privileges to app role ---------------------
GRANT SELECT, INSERT, DELETE, UPDATE, EXECUTE on SCHEMA::dbo to [ACTONE_APP_USER]
GO
EXEC sp_addrolemember ACTONE_APP_USER, ACTONE_APP_USER
GO

----- RCM READ ROLES ----
IF (select top 1 name from sys.database_principals where name = 'ACTONE_APP_READ' and type = 'R') IS NULL
 EXEC sp_addrole ACTONE_APP_READ
GO


----------------- Grant object privileges to read role ---------------------
GRANT SELECT on SCHEMA::dbo to [ACTONE_APP_READ]


go

