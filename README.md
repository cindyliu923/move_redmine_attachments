# move redmine attachments
simple to move your redmine attachments from one ticket to another

## Getting started

In redmine.rb change the variables to your's information:

```
@base_url = "https://redmine.your_redmine.com"
@api_token = "your_api_token"
@source_issue_id = your_source_issue_id
@target_issue_id = your_target_issue_id
```

run:
`ruby redmine.rb`
