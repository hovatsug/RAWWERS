OPENAPI_SOURCE ?= http://localhost:8000/openapi.json

.PHONY: gen-api

gen-api:
	dart run tool/filter_openapi.dart --source "$(OPENAPI_SOURCE)" --out openapi/schema.filtered.json
	dart run swagger_to_dart
	dart run build_runner build --delete-conflicting-outputs
