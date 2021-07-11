compose_up:
	docker-compose -f ./docker-compose.yml up -d

compose_down:
	docker-compose -f ./docker-compose.yml down

compose_ps:
	docker-compose -f ./docker-compose.yml ps

db_up:
	bundle exec rake db:migrate RAILS_ENV=development