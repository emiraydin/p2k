class Settings < Settingslogic
	if not Rails.env.test?
		source "#{Rails.root}/config/application.yml"
		namespace Rails.env
	else
		source "#{Rails.root}/config/application_test.yml"
		namespace Rails.env
	end
end