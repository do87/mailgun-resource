# mailgun-resource

This is a [Concourse CI](http://concourse-ci.org/) resource for sending email notifications to [mailgun](http://mailgun.com/)'s API

## Configuration

#### Resource type

Defining the mailgun resource name

``` yaml
resource_types:
- name: mailgun
  type: docker-image
  source:
    repository: do87/mailgun-resource
```

#### Add a resource

* `mailgun.key`: _Required._ The MailGun API key
* `mailgun.host`: _Required._ The MailGun API URL

Read more about MailGun's API [here](https://help.mailgun.com/hc/en-us/articles/202464990-How-do-I-start-sending-email-).

``` yaml
resources:
- name: mailgun
  type: mailgun
  source:
    mailgun:
      key: ((mailgun-key))
      host: ((mailgun-api))
```

#### Send notification

* `to`: _Optional._ Email address
* `to_committer`: _Optional._ If set to `true`, an email will be sent to the person that performed the latest commit where the `body` file is placed
* `body`: _Required._ Path to a file that contains the message we wish to send
* `subject`: _Required._ Email subject

``` yaml
- name: notify
  plan:
  - get: repo
  - put: mailgun
    params:
      to: ((monitoring-email))
      to_committer: true
      subject: "Subject"
      body: repo/notification.html
```

In the `body` file it is possible to use the metadata variables provided by Concourse:
https://concourse-ci.org/implementing-resources.html

## Example Scenario: Notify when pipeline fails

A common scenario is to notify on pipeline failure

#### using `on_failure` trigger
``` yaml
- name: test
  plan:
    - get: repo
      trigger: true
    - task: run-tests
      file: repo/ci/jobs/test.yaml
      on_failure:
        put: mailgun
        params:
          to_committer: true
          subject: "Pipeline failed"
          body: repo/ci/resources/failed.html
```

Example `failed.html` file:

``` html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>Concourse CI</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body style="margin: 0; padding: 0;">
 <table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
   <td>
    <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
      <tr>
        <td bgcolor="#212121" style="padding: 50px 40px; font-family: sans-serif; font-size: 14px;">
          Company Name
        </td>
      </tr>
      <tr>
        <td bgcolor="#E74C3C" style="padding: 20px 40px; font-family: sans-serif; font-size: 30px; color: #FFFFFF">
        <b>Pipeline failed!</b>
        </td>
      </tr><tr>
        <td bgcolor="#F4F4F4" style="padding: 20px 40px; font-family: sans-serif; font-size: 18px; color: #555555; line-height: 30px;">
          <b style="font-size: 22px">Description</b><hr size="1" />
          <table border="0" cellpadding="0" cellspacing="0"style="border-collapse: collapse;">
            <tr><td width="100"><b>Pipeline:</b></td><td>${BUILD_PIPELINE_NAME}</td></tr>
            <tr><td width="100"><b>Team:</b></td><td>${BUILD_TEAM_NAME}</td></tr>
            <tr><td><b>Job:</b></td><td>${BUILD_JOB_NAME}</td></tr>
            <tr><td><b>Build:</b></td><td>${BUILD_NAME}</td></tr>
          </table>

        </td>
      </tr><tr>
        <td bgcolor="#E1E1E1" style="padding: 20px 40px; font-family: sans-serif;">
          <a href="${ATC_EXTERNAL_URL}/teams/${BUILD_TEAM_NAME}/pipelines/${BUILD_PIPELINE_NAME}/jobs/${BUILD_JOB_NAME}/builds/${BUILD_NAME}" style="color: #444444">View Build</a>
        </td>
      </tr><tr>
        <td style="padding: 20px 40px; font-family: sans-serif; font-size: 14px;">
          ${ATC_EXTERNAL_URL}/teams/${BUILD_TEAM_NAME}/pipelines/${BUILD_PIPELINE_NAME}/jobs/${BUILD_JOB_NAME}/builds/${BUILD_NAME}
        </td>
      </tr>
    </table>
   </td>
  </tr>
 </table>
</body>
</html>

```
