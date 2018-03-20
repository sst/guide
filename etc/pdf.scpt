############################
# How to generate the PDFs #
############################
# 1. Update cover.html with the new version date
# 2. Open cover.html in safari and generate Cover.pdf
# 3. Place Cover.pdf in ~/Downloads folder
# 4. Ensure "Downloads" folder is an option when "Export to PDF…" in Safari
# 5. In terminal, run "osascript pdf.scpt"


set theChaptersStr to "index
who-is-this-guide-for
what-does-this-guide-cover
how-to-get-help
what-is-serverless
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
wrapping-up
giving-back
changelog
staying-up-to-date
api-gateway-and-lambda-logs
debugging-serverless-api-issues
serverless-environment-variables
stages-in-serverless-framework
configure-multiple-aws-profiles
customize-the-serverless-iam-policy
code-splitting-in-create-react-app
environments-in-create-react-app
connect-to-api-gateway-with-iam-auth
serverless-nodejs-starter"

set text item delimiters to "
"

set theChapters to text items of theChaptersStr


#################
# Download PDFs #
#################
#repeat with theCurrentChapter in theChapters
#  downloadPdf(theCurrentChapter)
#end repeat

##############
# Merge PDFs #
##############
set outputFile to "~/Downloads/ServerlessStack.pdf"

set pdfFiles to "~/Downloads/Cover.pdf"
repeat with theCurrentChapter in theChapters
  set pdfFiles to pdfFiles & " ~/Downloads/" & theCurrentChapter & ".pdf"
end repeat

do shell script "/System/Library/Automator/Combine\\ PDF\\ Pages.action/Contents/Resources/join.py " & "-o " & outputFile & " " & pdfFiles


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
          click menu item "Downloads" of menu 1 of pop up button "Where:"
          click button "Save"
        end tell

      end tell

      click menu item "Close Tab" of menu "File" of menu bar 1

    end tell

  end tell
end downloadPdf
