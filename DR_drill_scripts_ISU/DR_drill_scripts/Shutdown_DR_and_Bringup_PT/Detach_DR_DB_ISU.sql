USE [master]
GO
ALTER DATABASE [IP1] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'IP1'
GO
