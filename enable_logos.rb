vmdb = VMDB::Config.new("vmdb")
vmdb.config[:server][:custom_logo] = true
vmdb.config[:server][:custom_login_logo] = true
vmdb.save
