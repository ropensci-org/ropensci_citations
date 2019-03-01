RSCRIPT = Rscript --no-init-file

check:
	${RSCRIPT} -e "source('check_citations.R'); check_citation_file('citations.tsv')"

check_staged:
	${RSCRIPT} -e "source('check_citations.R'); check_citation_file('to_tweet.txt')"
