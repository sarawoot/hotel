compose_up:
	docker-compose -f ./docker-compose.yml up -d

compose_down:
	docker-compose -f ./docker-compose.yml down

compose_ps:
	docker-compose -f ./docker-compose.yml ps

compose_build:
	docker-compose build --no-cache

db_up:
	bundle exec rake db:migrate RAILS_ENV=development