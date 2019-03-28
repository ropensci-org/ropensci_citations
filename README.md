rOpenSci Citations Data
=======================

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for how to contribute.

- Citations data is in the `citations.tsv` file. The data is tab separated.
- Images used for tweets are in the `img/` folder
- tweets to be sent are in the `to_tweet.txt` file
- use case details are in the `use_cases.tsv` file
- The `package_handle_mapping.csv` is for mapping package names to twitter handles of orgs/people to mention

make commands:

- `make check`: check citations.tsv (checks tsv formatting, and images)
- `make check_staged`: check to_tweet.txt (checks tsv formatting, and images)
- `check_use_cases`: check use_cases.tsv (only checks for tsv formatting)

for both we attempt to read in with `readr::read_tsv` and print problems if there are any, and if not give a green check OK
