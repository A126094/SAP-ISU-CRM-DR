USE [master]
GO
ALTER DATABASE [CP1] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'CP1'
GO
