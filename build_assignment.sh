set -e

rm SendbirdUserManagerAssignment.zip || true
git restore .

rm -rf SendbirdUserManagerTests/Mocks || true
rm build_assignment.sh

zip -r SendbirdUserManagerAssignment.zip .

git restore .