############################
# How to generate the PDFs #
############################
# 1. Generate Cover.pdf with latest version date
#    a. Create "ebook" folder in ~/Downloads
#    b. update date in cover.html
#    c. open in safari file:///Users/frank/Sites/ServerlessStackCom/etc/cover.html
#    d. "Export to PDF…"
#    e. Place Cover.pdf in ~/ebook folder
# 2. Ensure "ebook" folder is an option when "Export to PDF…" in Safari
# 3. In terminal, run "osascript pdf.scpt"


set theChaptersStr to "who-is-this-guide-for
what-does-this-guide-cover
how-to-get-help
what-is-serverless
what-is-aws-lambda
why-create-serverless-apps
create-an-aws-account
create-an-iam-user
what-is-iam
what-is-an-arn
configure-the-aws-cli
create-a-dynamodb-table
create-an-s3-bucket-for-file-uploads
create-a-cognito-user-pool
create-a-cognito-test-user
setup-the-serverless-framework
add-support-for-es6-and-typescript
initialize-the-backend-repo
add-a-create-note-api
add-a-get-note-api
add-a-list-all-the-notes-api
add-an-update-note-api
add-a-delete-note-api
working-with-3rd-party-apis
setup-a-stripe-account
add-a-billing-api
load-secrets-from-env
test-the-billing-api
unit-tests-in-serverless
handle-api-gateway-cors-errors
deploy-the-apis
create-a-cognito-identity-pool
cognito-user-pool-vs-identity-pool
test-the-apis
create-a-new-reactjs-app
initialize-the-frontend-repo
add-app-favicons
setup-custom-fonts
setup-bootstrap
handle-routes-with-react-router
create-containers
adding-links-in-the-navbar
handle-404s
configure-aws-amplify
create-a-login-page
login-with-aws-cognito
add-the-session-to-the-state
load-the-state-from-the-session
clear-the-session-on-logout
redirect-on-login-and-logout
give-feedback-while-logging-in
create-a-custom-react-hook-to-handle-form-fields
create-a-signup-page
create-the-signup-form
signup-with-aws-cognito
add-the-create-note-page
call-the-create-api
upload-a-file-to-s3
list-all-the-notes
call-the-list-api
display-a-note
render-the-note-form
save-changes-to-a-note
delete-a-note
create-a-settings-page
add-stripe-keys-to-config
create-a-billing-form
connect-the-billing-form
setup-secure-pages
create-a-route-that-redirects
use-the-redirect-routes
redirect-on-login
getting-production-ready
what-is-infrastructure-as-code
what-is-aws-cdk
using-aws-cdk-with-serverless-framework
building-a-cdk-app-with-sst
configure-dynamodb-in-cdk
configure-s3-in-cdk
configure-cognito-user-pool-in-cdk
configure-cognito-identity-pool-in-cdk
connect-serverless-framework-and-cdk-with-sst
deploy-your-serverless-infrastructure
automating-serverless-deployments
setting-up-your-project-on-seed
configure-secrets-in-seed
deploying-through-seed
set-custom-domains-through-seed
test-the-configured-apis
automating-react-deployments
manage-environments-in-create-react-app
create-a-build-script
setting-up-your-project-on-netlify
custom-domain-in-netlify
frontend-workflow
debugging-full-stack-serverless-apps
setup-error-reporting-in-react
report-api-errors-in-react
setup-an-error-boundary-in-react
setup-error-logging-in-serverless
logic-errors-in-lambda-functions
unexpected-errors-in-lambda-functions
errors-outside-lambda-functions
errors-in-api-gateway
wrapping-up
further-reading
translations
giving-back
changelog
staying-up-to-date
best-practices-for-building-serverless-apps
organizing-serverless-projects
cross-stack-references-in-serverless
share-code-between-services
share-an-api-endpoint-between-services
deploy-a-serverless-app-with-dependencies
environments-in-serverless-apps
structure-environments-across-aws-accounts
manage-aws-accounts-using-aws-organizations
parameterize-serverless-resources-names
deploying-to-multiple-aws-accounts
deploy-the-resources-repo
deploy-the-api-services-repo
manage-environment-related-config
storing-secrets-in-serverless-apps
share-route-53-domains-across-aws-accounts
monitor-usage-for-environments
working-on-serverless-apps
invoke-lambda-functions-locally
invoke-api-gateway-endpoints-locally
creating-feature-environments
creating-pull-request-environments
promoting-to-production
rollback-changes
deploying-only-updated-services
tracing-serverless-apps-with-x-ray
wrapping-up-the-best-practices"

set text item delimiters to "
"

set theChapters to text items of theChaptersStr


########
# Main #
########
downloadPdfs(theChapters)
mergePdfs(theChapters)

##############
# Merge PDFs #
##############
on mergePdfs(theChapters)
  set outputFile to "~/Downloads/ebook/ServerlessStack.pdf"

  set pdfFiles to "~/Downloads/ebook/Cover.pdf"
  repeat with theCurrentChapter in theChapters
    set pdfFiles to pdfFiles & " ~/Downloads/ebook/" & theCurrentChapter & ".pdf"
  end repeat

  do shell script "/System/Library/Automator/Combine\\ PDF\\ Pages.action/Contents/Resources/join.py " & "-o " & outputFile & " " & pdfFiles
end mergePdfs

#################
# Download PDFs #
#################
on downloadPdfs(theChapters)
  repeat with theCurrentChapter in theChapters
    if not(checkFileExist(theCurrentChapter)) then
      downloadPdf(theCurrentChapter)
    end if
  end repeat
end downloadPdfs

on checkFileExist(theChapterName)
  set basePath to POSIX path of (path to home folder) & "Downloads/ebook/"

  tell application "Finder"
    return exists basePath & theChapterName & ".pdf" as POSIX file
  end tell
end checkFileExist

on downloadPdf(theChapterName)
  tell application "System Events"

    tell process "Safari"
      set frontmost to true

      if ((theChapterName as string) is equal to "index") then
        set urlPath to theChapterName
      else
        set urlPath to "chapters/" & theChapterName
      end if
      open location "https://serverless-stack.com/" & urlPath & ".html"

      delay 1

      repeat until menu item "Export as PDF…" of menu "File" of menu bar 1 exists
        delay 0.2
      end repeat
      repeat
        if ((value of menu item "Export as PDF…" of menu "File" of menu bar 1 is enabled) = true)
          exit repeat
        end if
        delay 0.2
      end repeat
      click menu item "Export as PDF…" of menu "File" of menu bar 1

      tell window 1
        repeat until sheet 1 exists
        end repeat

        tell sheet 1
          keystroke theChapterName
          click pop up button "Where:"

          repeat until menu 1 of pop up button "Where:" exists
          end repeat
          click menu item "ebook" of menu 1 of pop up button "Where:"
          click button "Save"
        end tell

      end tell

      delay 2

      click menu item "Close Tab" of menu "File" of menu bar 1

    end tell

  end tell
end downloadPdf
