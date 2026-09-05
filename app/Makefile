OPENAPI_SOURCE ?= http://localhost:8000/openapi.json

.PHONY: gen gen-api

# Use this for ordinary codegen (Riverpod providers, freezed, json_serializable)
# instead of calling build_runner directly.
#
# build_runner regenerates lib/api/api_client/*.g.dart every run, which
# reintroduces a swagger_to_dart bug that emits calls to `.fromJson`
# constructors that do not exist (see tool/fix_generated_client_bugs.dart).
# `dart run build_runner build` on its own therefore leaves the tree in a
# state where `flutter analyze` passes - lib/api is excluded from analysis -
# and every `flutter test` fails to compile. Running the fixer here means the
# obvious command is also the correct one.
gen:
	dart run build_runner build --delete-conflicting-outputs
	dart run tool/fix_generated_client_bugs.dart

# Full regeneration from the live backend schema.
gen-api:
	dart run tool/filter_openapi.dart --source "$(OPENAPI_SOURCE)" --out openapi/schema.filtered.json
	dart run swagger_to_dart
	dart run build_runner build --delete-conflicting-outputs
	dart run tool/fix_generated_client_bugs.dart
