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


set theChaptersStr to "index
who-is-this-guide-for
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
add-support-for-es6-es7-javascript
add-a-create-note-api
add-a-get-note-api
add-a-list-all-the-notes-api
add-an-update-note-api
add-a-delete-note-api
handle-api-gateway-cors-errors
deploy-the-apis
create-a-cognito-identity-pool
cognito-user-pool-vs-identity-pool
test-the-apis
create-a-new-reactjs-app
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
setup-secure-pages
create-a-route-that-redirects
use-the-redirect-routes
redirect-on-login
deploy-the-frontend
create-an-s3-bucket
deploy-to-s3
create-a-cloudfront-distribution
setup-your-domain-with-cloudfront
setup-www-domain-redirect
setup-ssl
deploy-updates
update-the-app
deploy-again
getting-production-ready
initialize-the-backend-repo
organize-the-backend-repo
what-is-infrastructure-as-code
configure-dynamodb-in-serverless
configure-s3-in-serverless
configure-cognito-user-pool-in-serverless
configure-cognito-identity-pool-in-serverless
use-environment-variables-in-lambda-functions
deploy-your-serverless-infrastructure
working-with-3rd-party-apis
setup-a-stripe-account
add-a-billing-api
load-secrets-from-env-yml
test-the-billing-api
unit-tests-in-serverless
automating-serverless-deployments
setting-up-your-project-on-seed
configure-secrets-in-seed
deploying-through-seed
set-custom-domains-through-seed
test-the-configured-apis
monitoring-deployments-in-seed
initialize-the-frontend-repo
manage-environments-in-create-react-app
create-a-settings-page
add-stripe-keys-to-config
create-a-billing-form
connect-the-billing-form
automating-react-deployments
create-a-build-script
setting-up-your-project-on-netlify
custom-domain-in-netlify
frontend-workflow
wrapping-up
further-reading
translations
giving-back
changelog
staying-up-to-date
organizing-serverless-projects
cross-stack-references-in-serverless
dynamodb-as-a-serverless-service
s3-as-a-serverless-service
api-gateway-domains-across-services
cognito-as-a-serverless-service
deploying-multiple-services-in-serverless
api-gateway-and-lambda-logs
debugging-serverless-api-issues
serverless-environment-variables
stages-in-serverless-framework
configure-multiple-aws-profiles
customize-the-serverless-iam-policy
mapping-cognito-identity-id-and-user-pool-id
connect-to-api-gateway-with-iam-auth
serverless-nodejs-starter
manage-user-accounts-in-aws-amplify
handle-forgot-and-reset-password
allow-users-to-change-passwords
allow-users-to-change-their-email
code-splitting-in-create-react-app
environments-in-create-react-app
facebook-login-with-cognito-using-aws-amplify"

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
      repeat until menu item "Export as PDF…" of menu "File" of menu bar 1 is enabled
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

      click menu item "Close Tab" of menu "File" of menu bar 1

    end tell

  end tell
end downloadPdf
