Declare @Old_name VARCHAR(40);
Declare @New_name VARCHAR(40);
CREATE TABLE  ip1.Server_Mapping (Old VARCHAR(20), New VARCHAR(20));
BULK INSERT ip1.Server_Mapping FROM 'E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Server_mapping.txt' WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
DECLARE @cnt INT = 0;
DECLARE @RowCount INT=(Select count(*) from ip1.Server_Mapping);
WHILE @cnt < @RowCount
BEGIN
SET @Old_name=(SELECT TOP(1) Old from ip1.Server_Mapping);
SET @New_name=(SELECT TOP(1) New from ip1.Server_Mapping);
----############## START OF UPDATE TABLE ########################################################
--SMT1
UPDATE ip1.RFCSYSACL SET RFCCREDEST= REPLACE(RFCCREDEST, @Old_name,@New_name) WHERE  RFCCREDEST like ('%'+@Old_name+'%');
UPDATE ip1.RFCSYSACL SET RFCMSGSRV= REPLACE(RFCMSGSRV, @Old_name,@New_name) WHERE  RFCMSGSRV like ('%'+@Old_name+'%');
UPDATE ip1.RFCSYSACL SET RFCREGDEST= REPLACE(RFCREGDEST, @Old_name,@New_name) WHERE  RFCREGDEST like ('%'+@Old_name+'%');
--SMLG/RZ12
UPDATE ip1.RZLLITAB SET APPLSERVER= REPLACE(APPLSERVER, @Old_name,@New_name) WHERE  APPLSERVER like  ('%'+@Old_name+'%');
--FILE
UPDATE ip1.PATH SET PATHEXTERN= REPLACE(PATHEXTERN, @Old_name,@New_name) WHERE  PATHEXTERN like  ('%'+@Old_name+'%');
--AL11
UPDATE ip1.USER_DIR SET DIRNAME= REPLACE(DIRNAME, @Old_name,@New_name) WHERE  DIRNAME like  ('%'+@Old_name+'%');
UPDATE ip1.USER_DIR SET SVRNAME= REPLACE(SVRNAME, @Old_name,@New_name) WHERE  SVRNAME like  ('%'+@Old_name+'%');
--SM49
UPDATE ip1.SXPGCOSTAB SET OPCOMMAND= REPLACE(OPCOMMAND, @Old_name,@New_name) WHERE  OPCOMMAND like  ('%'+@Old_name+'%');
UPDATE ip1.SXPGCOSTAB SET PARAMETERS= REPLACE(PARAMETERS, @Old_name,@New_name) WHERE  PARAMETERS like  ('%'+@Old_name+'%');
--SLDAPICUST
--RZ70
UPDATE ip1.SLDAGADM SET GWHOST= REPLACE(GWHOST, @Old_name,@New_name) WHERE  GWHOST like  ('%'+@Old_name+'%');
--SXMB_ADM
--RZ04(Check in ID1 showing glawi611)
UPDATE ip1.TPFID SET HOST= REPLACE(HOST,  @Old_name,@New_name) WHERE  HOST like ('%'+@Old_name+'%');
UPDATE ip1.TPFID SET APSERVER= REPLACE(APSERVER,  @Old_name,@New_name) WHERE  APSERVER like ('%'+@Old_name+'%');
UPDATE ip1.TPFID SET PFINST= REPLACE(PFINST,  @Old_name,@New_name) WHERE  PFINST like ('%'+@Old_name+'%');
UPDATE ip1.TPFID SET PFSTART= REPLACE(PFSTART,  @Old_name,@New_name) WHERE  PFSTART like ('%'+@Old_name+'%');
UPDATE ip1.TPFID SET PFLINSNAME= REPLACE(PFLINSNAME, @Old_name,@New_name) WHERE  PFLINSNAME like ('%'+@Old_name+'%');
UPDATE ip1.TPFID SET PFLSTRNAME= REPLACE(PFLSTRNAME,  @Old_name,@New_name) WHERE  PFLSTRNAME like ('%'+@Old_name+'%');
UPDATE ip1.TPFHT SET PFNAME= REPLACE(PFNAME,  @Old_name,@New_name) WHERE  PFNAME like ('%'+@Old_name+'%');
UPDATE ip1.TPFHT SET PFFILE= REPLACE(PFFILE,  @Old_name,@New_name) WHERE  PFFILE like ('%'+@Old_name+'%');
UPDATE ip1.TPFHT SET SERVERNAME= REPLACE(SERVERNAME,  @Old_name,@New_name) WHERE  SERVERNAME like ('%'+@Old_name+'%');
UPDATE ip1.TPFET SET PFNAME= REPLACE(PFNAME,  @Old_name,@New_name) WHERE  PFNAME like ('%'+@Old_name+'%');
UPDATE ip1.TPFET SET PVALUE= REPLACE(PVALUE,  @Old_name,@New_name) WHERE  PVALUE like ('%'+@Old_name+'%');

--STMS (Check for transport directory)
UPDATE ip1.ALMBCDATA SET MTMCNAME= REPLACE(MTMCNAME, @Old_name,@New_name) WHERE  MTMCNAME like ('%'+@Old_name+'%');
UPDATE ip1.TMSCDES SET RFCHOST= REPLACE(RFCHOST, @Old_name,@New_name) WHERE  RFCHOST like  ('%'+@Old_name+'%');
UPDATE ip1.TMSPCONF SET VALUE=REPLACE (VALUE,@Old_name,@New_name) WHERE  VALUE like  ('%'+@Old_name+'%');
UPDATE ip1.TMSPCONF SET VALUE=REPLACE (VALUE,@Old_name,@New_name) WHERE  VALUE like  ('%'+@Old_name+'%');
--PSE
UPDATE ip1.SSF_PSE_H SET HOST= REPLACE(HOST, @Old_name,@New_name) WHERE  HOST like  ('%'+@Old_name+'%');
UPDATE ip1.SSF_PSE_H SET ID= REPLACE(ID, @Old_name,@New_name) WHERE  ID like  ('%'+@Old_name+'%');
UPDATE ip1.SSF_PSE_HIST SET HOST= REPLACE(HOST, @Old_name,@New_name) WHERE  HOST like  ('%'+@Old_name+'%');

--RFC
UPDATE ip1.RFCDES SET RFCOPTIONS= REPLACE(RFCOPTIONS, @Old_name,@New_name) WHERE  RFCOPTIONS like  ('%'+@Old_name+'%');


----############## END OF UPDATE TABLE ########################################################
DELETE TOP(1) FROM ip1.Server_Mapping;
SET @cnt = @cnt + 1;
END;
DROP TABLE [ip1].[Server_Mapping];

--- JOB hold in system
Update ip1.TBTCO set STATUS='P' where STATUS in ('R','Y','S','Z');
Update ip1.TBTCO set STATUS='S' where STATUS ='P' and JOBNAME='RDDIMPDP';

--License Key apply

Insert into ip1.SAPLIKEY values ('0002LK0003IP10011M18681397400013NetWeaver_MSS','001021474836470001P0424MIIBOgYJKoZIhvcNAQcCoIIBKzCCAScCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHATGCAQYwggECAgEBMFgwUjELMAkGA1UEBhMCREUxHDAaBgNVBAoTE215U0FQLmNvbSBXb3JrcGxhY2UxJTAjBgNVBAMTHG15U0FQLmNvbSBXb3JrcGxhY2UgQ0EgKGRzYSkCAgGhMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xODA3MDkwNjM5NDZaMCMGCSqGSIb3DQEJBDEWBBRVKUVPAMqGQ3Uo3cWQb/h+b8ggvzAJBgcqhkjOOAQDBC4wLAIUOjQ4jDYUABeisBv5hidV1HN7cKMCFEf19Sh1kum4So9dlsl1LJZEhxMe001000202537280008201807080008999912310018000000000310560941');
Insert into ip1.SAPLIKEY values ('0002LK0003IP10011Q06486646430013NetWeaver_MSS','001021474836470001P0428MIIBOwYJKoZIhvcNAQcCoIIBLDCCASgCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHATGCAQcwggEDAgEBMFgwUjELMAkGA1UEBhMCREUxHDAaBgNVBAoTE215U0FQLmNvbSBXb3JrcGxhY2UxJTAjBgNVBAMTHG15U0FQLmNvbSBXb3JrcGxhY2UgQ0EgKGRzYSkCAgGhMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xODA3MDkwNjIyNTVaMCMGCSqGSIb3DQEJBDEWBBQSLMgLcQDbZJIdi4BgwQXl8/+ovjAJBgcqhkjOOAQDBC8wLQIUcLuDaGcL1zmWA96c84HmCThd1ZYCFQCSWrLuOtDYU/M6h7kx+m1VK+ossA==001000202537280008201807080008999912310018000000000310560941');

--VAULT
UPDATE ip1.ZIFITT044 SET URL= 'https://glawiwde1.agl.int/PCIDSSWeb/PCIDSS/DirectDebitEntry?Param=' WHERE  SYS_ID = 'IP1100'; --ISU server PCIDSS
UPDATE ip1.ZICSTT510 SET URL= 'https://glawiwde1.agl.int/PCIDSSWeb/pcidss/paymentpage?Param=' WHERE  SYS_ID = 'IP1'; --ISU server Payment Hub
--SALMAT connectivity for FTP (Collect addiional info)
