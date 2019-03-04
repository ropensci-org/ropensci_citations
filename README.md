rOpenSci Citations Data
=======================

See [CONTRIBUTING.md][] for how to contribute.

- Citations data is in the `citations.tsv` file. The data is tab separated.
- Images used for tweets are in the `img/` folder
- tweets to be sent are in the `to_tweet.txt` file
- The `package_handle_mapping.csv` is for mapping package names to twitter handles of orgs/people to mention

make commands:

- `make check`: check citations.tsv
- `make check_staged`: check to_tweet.txt

for both we attempt to read in with `readr::read_tsv` and print problems if there are any, and if not give a green check OK
