set -e

rm SendbirdUserManagerAssignment.zip || true
git restore .

rm -rf Tests/SendbirdUserManagerTests/Mocks || true
rm build_assignment.sh
rm README.md

zip -r SendbirdUserManagerAssignment.zip .

git restore .
