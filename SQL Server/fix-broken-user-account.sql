exec sp_change_users_login 'Report'
exec sp_change_users_login 'Auto_Fix', '<login name>', NULL, 'cf'
exec sp_change_users_login 'Update_One', '<login name>', '<login name>'

