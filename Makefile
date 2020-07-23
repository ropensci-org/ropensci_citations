RSCRIPT = Rscript --no-init-file

check:
	${RSCRIPT} -e "source('src/check_citations.R'); check_citation_file('citations.tsv')"

check_all:
	${RSCRIPT} -e "source('src/check_citations.R'); check_citation_file('citations_all.tsv')"

check_staged:
	${RSCRIPT} -e "source('src/check_citations.R'); check_citation_file('to_tweet.txt')"

check_use_cases:
	${RSCRIPT} -e "source('src/check_citations.R'); check_citation_file('use_cases.tsv')"

gather_mentions:
	${RSCRIPT} -e "source('src/gather_mentions.R')"

json:
	${RSCRIPT} -e "source('src/citations_to_json.R'); to_json('citations_all.tsv')"

append_parts: json
	ruby src/append_parts.rb
