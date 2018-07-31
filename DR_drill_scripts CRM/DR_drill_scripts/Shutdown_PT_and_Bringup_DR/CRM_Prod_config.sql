Declare @Old_name VARCHAR(40);
Declare @New_name VARCHAR(40);
CREATE TABLE  cp1.Server_Mapping (Old VARCHAR(20), New VARCHAR(20));
BULK INSERT cp1.Server_Mapping FROM 'E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Server_mapping.txt' WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
DECLARE @cnt INT = 0;
DECLARE @RowCount INT=(Select count(*) from cp1.Server_Mapping);
WHILE @cnt < @RowCount
BEGIN
SET @Old_name=(SELECT TOP(1) Old from cp1.Server_Mapping);
SET @New_name=(SELECT TOP(1) New from cp1.Server_Mapping);
----############## START OF UPDATE TABLE ########################################################
--SMT1
UPDATE cp1.RFCSYSACL SET RFCCREDEST= REPLACE(RFCCREDEST, @Old_name,@New_name) WHERE  RFCCREDEST like ('%'+@Old_name+'%');
UPDATE cp1.RFCSYSACL SET RFCMSGSRV= REPLACE(RFCMSGSRV, @Old_name,@New_name) WHERE  RFCMSGSRV like ('%'+@Old_name+'%');
UPDATE cp1.RFCSYSACL SET RFCREGDEST= REPLACE(RFCREGDEST, @Old_name,@New_name) WHERE  RFCREGDEST like ('%'+@Old_name+'%');
--SMLG/RZ12
UPDATE cp1.RZLLITAB SET APPLSERVER= REPLACE(APPLSERVER, @Old_name,@New_name) WHERE  APPLSERVER like  ('%'+@Old_name+'%');
--FILE
UPDATE cp1.PATH SET PATHEXTERN= REPLACE(PATHEXTERN, @Old_name,@New_name) WHERE  PATHEXTERN like  ('%'+@Old_name+'%');
--AL11
UPDATE cp1.USER_DIR SET DIRNAME= REPLACE(DIRNAME, @Old_name,@New_name) WHERE  DIRNAME like  ('%'+@Old_name+'%');
UPDATE cp1.USER_DIR SET SVRNAME= REPLACE(SVRNAME, @Old_name,@New_name) WHERE  SVRNAME like  ('%'+@Old_name+'%');
--SM49
UPDATE cp1.SXPGCOSTAB SET OPCOMMAND= REPLACE(OPCOMMAND, @Old_name,@New_name) WHERE  OPCOMMAND like  ('%'+@Old_name+'%');
UPDATE cp1.SXPGCOSTAB SET PARAMETERS= REPLACE(PARAMETERS, @Old_name,@New_name) WHERE  PARAMETERS like  ('%'+@Old_name+'%');
--SLDAPICUST
--RZ70
UPDATE cp1.SLDAGADM SET GWHOST= REPLACE(GWHOST, @Old_name,@New_name) WHERE  GWHOST like  ('%'+@Old_name+'%');
--SXMB_ADM
--RZ04
UPDATE cp1.TPFID SET HOST= REPLACE(HOST,  @Old_name,@New_name) WHERE  HOST like ('%'+@Old_name+'%');
UPDATE cp1.TPFID SET APSERVER= REPLACE(APSERVER,  @Old_name,@New_name) WHERE  APSERVER like ('%'+@Old_name+'%');
UPDATE cp1.TPFID SET PFINST= REPLACE(PFINST,  @Old_name,@New_name) WHERE  PFINST like ('%'+@Old_name+'%');
UPDATE cp1.TPFID SET PFSTART= REPLACE(PFSTART,  @Old_name,@New_name) WHERE  PFSTART like ('%'+@Old_name+'%');
UPDATE cp1.TPFID SET PFLINSNAME= REPLACE(PFLINSNAME, @Old_name,@New_name) WHERE  PFLINSNAME like ('%'+@Old_name+'%');
UPDATE cp1.TPFID SET PFLSTRNAME= REPLACE(PFLSTRNAME,  @Old_name,@New_name) WHERE  PFLSTRNAME like ('%'+@Old_name+'%');
UPDATE cp1.TPFHT SET PFNAME= REPLACE(PFNAME,  @Old_name,@New_name) WHERE  PFNAME like ('%'+@Old_name+'%');
UPDATE cp1.TPFHT SET PFFILE= REPLACE(PFFILE,  @Old_name,@New_name) WHERE  PFFILE like ('%'+@Old_name+'%');
UPDATE cp1.TPFHT SET SERVERNAME= REPLACE(SERVERNAME,  @Old_name,@New_name) WHERE  SERVERNAME like ('%'+@Old_name+'%');
UPDATE cp1.TPFET SET PFNAME= REPLACE(PFNAME,  @Old_name,@New_name) WHERE  PFNAME like ('%'+@Old_name+'%');
UPDATE cp1.TPFET SET PVALUE= REPLACE(PVALUE,  @Old_name,@New_name) WHERE  PVALUE like ('%'+@Old_name+'%');
--WEB UI
UPDATE cp1.HTTPURLLOC SET HOST = REPLACE(HOST,  @Old_name,@New_name) WHERE  HOST like ('%'+@Old_name+'%');
--CRM7 POST STEP
UPDATE cp1.CRMC_IC_BORADM SET ITS_URL = REPLACE(ITS_URL,  @Old_name,@New_name) WHERE  ITS_URL like ('%'+@Old_name+'%');
--STMS (Check for transport directory)
UPDATE cp1.ALMBCDATA SET MTMCNAME= REPLACE(MTMCNAME, @Old_name,@New_name) WHERE  MTMCNAME like ('%'+@Old_name+'%');
UPDATE cp1.TMSCDES SET RFCHOST= REPLACE(RFCHOST, @Old_name,@New_name) WHERE  RFCHOST like  ('%'+@Old_name+'%');
UPDATE cp1.TMSPCONF SET VALUE=REPLACE (VALUE,@Old_name,@New_name) WHERE  VALUE like  ('%'+@Old_name+'%');
UPDATE cp1.TMSPCONF SET VALUE=REPLACE (VALUE,@Old_name,@New_name) WHERE  VALUE like  ('%'+@Old_name+'%');
--PSE
UPDATE cp1.SSF_PSE_H SET HOST= REPLACE(HOST, @Old_name,@New_name) WHERE  HOST like  ('%'+@Old_name+'%');
UPDATE cp1.SSF_PSE_H SET ID= REPLACE(ID, @Old_name,@New_name) WHERE  ID like  ('%'+@Old_name+'%');
UPDATE cp1.SSF_PSE_HIST SET HOST= REPLACE(HOST, @Old_name,@New_name) WHERE  HOST like  ('%'+@Old_name+'%');
--RFC
UPDATE cp1.RFCDES SET RFCOPTIONS= REPLACE(RFCOPTIONS, @Old_name,@New_name) WHERE  RFCOPTIONS like  ('%'+@Old_name+'%');
UPDATE cp1.RFCDES SET RFCOPTIONS= REPLACE(RFCOPTIONS, 'glawi1323','glawi1256') WHERE  RFCOPTIONS like  ('%'+'glawi1323'+'%') and RFCDEST='ADS';
----############## END OF UPDATE TABLE ########################################################
DELETE TOP(1) FROM cp1.Server_Mapping;
SET @cnt = @cnt + 1;
END;
DROP TABLE [cp1].[Server_Mapping];

--- JOB hold in system
Update cp1.TBTCO set STATUS='P' where STATUS in ('R','Y','S','Z');
Update cp1.TBTCO set STATUS='S' where STATUS ='P' and JOBNAME='RDDIMPDP';

--Apply License key
Insert into cp1.SAPLIKEY values ('0002LK0003CP10011Q07074280750013NetWeaver_MSS','001021474836470001P0428MIIBOwYJKoZIhvcNAQcCoIIBLDCCASgCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHATGCAQcwggEDAgEBMFgwUjELMAkGA1UEBhMCREUxHDAaBgNVBAoTE215U0FQLmNvbSBXb3JrcGxhY2UxJTAjBgNVBAMTHG15U0FQLmNvbSBXb3JrcGxhY2UgQ0EgKGRzYSkCAgGhMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xODA3MDkwNjMzMzVaMCMGCSqGSIb3DQEJBDEWBBQC7Ur1YnzMqxRxooCEaH3+LxSz6zAJBgcqhkjOOAQDBC8wLQIVAIIj+HWVsm55GikIqHHza8Z8BDe6AhQRhtNRemjHBEi9tl9AKVAmv8L1qA==001000202539310008201807080008999912310018000000000310569162');
Insert into cp1.SAPLIKEY values ('0002LK0003CP10011P10946723730013NetWeaver_MSS','001021474836470001P0424MIIBOgYJKoZIhvcNAQcCoIIBKzCCAScCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHATGCAQYwggECAgEBMFgwUjELMAkGA1UEBhMCREUxHDAaBgNVBAoTE215U0FQLmNvbSBXb3JrcGxhY2UxJTAjBgNVBAMTHG15U0FQLmNvbSBXb3JrcGxhY2UgQ0EgKGRzYSkCAgGhMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xODA3MTAwMjAwNDdaMCMGCSqGSIb3DQEJBDEWBBQxUwGnbrGzjlUtwIZR2/4CN+Wm9TAJBgcqhkjOOAQDBC4wLAIUbAJ6YZOC3+6U6jzrYgSox1NXYvkCFCvVMTd8AUhZNvt6BVF2O5vRRjFW001000202539310008201807090008999912310018000000000310569162');

--SALMAT connectivity for FTP (Collect addiional info) Table ::ZCCATT010
