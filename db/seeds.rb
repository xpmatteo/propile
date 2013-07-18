# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


PropileConfig.create! name: "voting_active", value: "false"
PropileConfig.create! name: "submit_session_active", value: "true"

p = Presenter.new name: "First maintainer"
p.account.email = "maintainer@example.com"
p.account.role = "maintainer"
p.account.confirmed_at = Time.now
p.account.password = "pippo"
p.save!
Account.authenticate_by_email_and_password("maintainer@example.com", "pippo") or raise "Should authenticate with pippo"

