.PHONY: setup clean format lint test build-runner

# Install dependencies and setup environment
setup:
	flutter clean
	flutter pub get

# Format code automatically
format:
	dart format lib/

# Run the linter to catch errors before committing
lint:
	flutter analyze

# Run all tests
test:
	flutter test

# Generate freezed/json_serializable files (we will need this later for our Data Models)
build-runner:
	dart run build_runner build --delete-conflicting-outputs