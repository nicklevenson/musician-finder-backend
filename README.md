# README
Matchup Music Backend!

To get started, have ruby 3.0 / rails 6.1.3 installed in your local environment. 

Go ahead and run bundle install

For Oauth and JWT you will need to configure the rails credentials file - let me know and I can help you/send you proper credentials. Run EDITOR="[your code editor] --wait" rails credentials:edit to open that file.

Once the creds are solid, create the database with rails:db:create

Migrate migrations with rails:db:migrate

Lastly, if you want to seed the db run rails:db:seed - note that these seeds are minimal and are set up to give the first user in the db (login to the app before you seed the db) some data to work with in the frontend.

Feel free to mess around with the seed file.

To start the server, run rails s. Everything is configured to have the rails api run on localhost:3000. So make sure the frontend is running on localhost:3001





