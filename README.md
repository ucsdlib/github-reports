# UC San Diego Library GitHub Reports #

The reports contained in this repository are used for keeping track of the
contributions made by the UC San Diego Library development team in both local
and open source/community projects on GitHub.

## Setup ##
1. Install Ruby 2.x
2. Install bundler `gem install bundler`
3. Clone repository `git clone https://github.com/ucsdlib/github-reports.git`
4. `cd github-reports`
5. `bundle install`
6. Setup `config.yml` as follows:
    1. `cp config.yml.sample config.yml`
    1. Add your GitHub username and password to the `user` and `password`
       fields, replacing the existing boilerplate defaults
    1. Create a [personal access token for Gitlab][pac-gitlab], check the `api`
       Scope checkbox when creating it. Add this token to LastPass, or whatever
       fits your workflow
    1. Add your Gitlab personal access token to the `personal_access_token`
       field, replacing the existing boilerplate defaults
7. Run report(s) below as needed

## Reports ##

### Open Issues
Where: `open_issues.rb`
What: A list of all tickets assigned to members of the development team that are
currently `open`

To Use:
1. `./open_issues.rb`
2. Open up the generated `open_issues.report` page and do a select all +
   copy
3. Follow instructions in [Embedding Report Data in
   Confluence](#embedding-report-data-in-confluence) section

### Closed Issues
Where: `closed_issues.rb`
What: A list of closed issues between a specified time frame. Usually a 2 week
Sprint, but could be for a month, year, etc.

To Use:
1. This script expects two arguments. A `start_date` and an `end_date`. These
   should be formatted as follows `YYYY-MM-DD`. Example: `2017-12-01`
1. `./closed_issues.rb 2017-12-01 2017-12-31`
More examples:
    1. 2 week period: `2017-12-01 2017-12-15`
    1. 4 week period: `2017-12-01 2017-12-31`
    1. Year (this will be SLOW): `2017-12-01 2018-12-01`
1. Open up the generated `closed_issues<date-range>.report` page and do a select all +
   copy. An example filename: `closed_issues_2017-12-01-2017-12-31.report`
1. Follow instructions in [Embedding Report Data in
   Confluence](#embedding-report-data-in-confluence) section


## Embedding Report Data in Confluence ##
Confluence supports embedding wiki markup, which is how we get our generated
report data into a page. [This is documented by Atlassian][markup] if you would like
further information.

1. Open Confluence/LiSN and open (or create) the page you wish to enter the
   report data
2. Click the (+) icon and choose `Insert Markup`
3. Ensure the `Confluence Wiki` option is selected
4. Paste in the report data and ensure it looks correct in the Preview pane
5. Click `Insert` to put embed the report data into the page
6. Edit the page as needed and save

[markup]:https://confluence.atlassian.com/doc/confluence-wiki-markup-251003035.html#ConfluenceWikiMarkup-Tables
[pac-gitlab]:https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#creating-a-personal-access-token
