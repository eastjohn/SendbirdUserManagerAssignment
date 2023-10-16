set -e

rm SendbirdUserManagerTests.zip
git restore .

rm -rf SendbirdUserManagerTests/Mocks
rm build_assignment.sh

zip -r SendbirdUserManagerTests.zip .

git restore .
