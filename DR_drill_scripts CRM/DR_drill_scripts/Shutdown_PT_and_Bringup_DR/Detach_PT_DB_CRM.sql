USE [master]
GO
ALTER DATABASE [CPT] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'CPT'
GO