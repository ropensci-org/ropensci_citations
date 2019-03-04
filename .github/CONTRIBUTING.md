# CONTRIBUTING #

### Pull requests

Most citations in `citations.tsv` have simply been the package name, DOI, citation. We have recently added an image from the article if there is an appropriate one, and a very short snippet describing the research.

To contribute a new citation, first make sure it is not already in `citations.tsv`, then:

- (optional) Add an image for the tweet in the `img/` folder if you can find an appropriate one that conveys something interesting, or at least looks cool :)
- (optional) As needed, add an entry to `package_handle_mapping.csv` for mapping package names to twitter handles of orgs/people to mention that are either maintainers of the package or organizations that the package is a client for, e.g.
- Add an entry (row) to the `to_tweet.txt` file, which is the staging area for tweets to be sent. The format for each row:

- `name`: package name
- `doi`: DOI (if there is one)
- `citation`: the citation; we generally follow APA here. It must have a link at the end; if there is a DOI use `<https://doi.org/{DOI}>`; if there is no DOI use whatever the link is to the article `<https://whatever.link>`)
- `img_path`: path to the image, should be prefixed with `img/`, and then something meaningful, e.g., like `PinarEtal2019AnnalsOfMicrobiology.png`
- `research_snippet`: very brief description of the research. This snippet will be prefixed with _in their work on_, so keep that in mind.

Do not send changes directly to the `citations.tsv` file, as it is used with our [twitter bot](https://twitter.com/rocitations), and any changes to previously tweeted citations may trigger a new tweet. Open an issue if you think something should be changed in this file.

When the PR is merged, within an hour (our Twitter bot runs once per hour) the tweet will be sent out.
