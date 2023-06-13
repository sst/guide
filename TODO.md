# Guide Typescript & PNPM Updates

As I work through the guide, I add notes and I also read the comments and adding any relevant notes I see as of May 18(ish).  

## Site Wide

#### Changes
- Added .idea to .gitignore
- Added .idea to Jekyll Exclude list

#### Notes
- [ ] Consider accessibility features
    * http://www.goring.org/resources/accessibility.html
    * https://github.com/benbalter/ra11y
    * adding an indicator for links that open in new tabs
- [ ] Consider adding "Archived" banner to the top of any parts of the site that are kept but are not intended for current reference for example, all the pages [in this section](http://localhost:4000/guide.html#archives).

## Guide

#### Changes
- Updated External Links to open a new tab.
- Updated SASS for blockquote within post-content to not be enormous.
- Added a few classes for Notes and Asides

#### Notes
- [ ] TODO: Resolve SST Console Warning [See the migration guide](https://a.co/7PzMCcy)

      (node:85684) NOTE: We are formalizing our plans to enter AWS SDK for JavaScript (v2) into maintenance mode in 2023.

      Please migrate your code to use AWS SDK for JavaScript (v3).
      For more information, check the migration guide at https://a.co/7PzMCcy
      (Use `node --trace-warnings ...` to show where the warning was created)
      16:14:43.391

- [ ] TODO: Clean up legacy guide files so it doesn't clutter the current fileset.
- [ ] TODO: Correctly manage the path_id variable in code examples to ensure they are present without code duplication.
- [ ] TODO: Switch from Amplify API to RestApi or GraphQLAPI based on note in API.d.ts (See Warning in console.sst.dev)
- [ ] Consider adding a chapter on accessibility in the frontend creation section.
  * [React Accessibility](https://legacy.reactjs.org/docs/accessibility.html) - New Accessibility guides are still pending based on announcement on 3/16/2023
  * https://www.freecodecamp.org/news/react-accessibility-tools-build-accessible-react-apps/
  * https://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Client-side_JavaScript_frameworks/React_accessibility

## Chapter Specific

### What Does This Guide Cover
#### Notes (From Discourse comments)
- [ ] [Consider using Next.js for the guide](https://discourse.sst.dev/t/what-does-this-guide-cover/83/7?u=christinep2)
- [ ] [Consider switching example to React Native](https://discourse.sst.dev/t/what-does-this-guide-cover/83/8?u=christinep2)

### How to Get Help?
_no specific changes_

### What is Serverless?
#### Changes
 - Removed link to the What is AWS Lambda chapter as it encourages skipping the rest of the current page.

### What is AWS Lambda?
#### Notes
- [ ] [Consider decreasing specificity in Lambda Spec Description](/chapters/what-is-aws-lambda.html#lambda-specs) - As AWS modifies its offerings, the description can be outdated.  By speaking in generalities and linking directly to AWS for specificity the document will be less fragile.

### Why Create Serverless Apps?
#### Notes
- [ ] Consider specifying a timeframe on the cost calculation to account for pricing changes over time. 

### Create an AWS Account
#### Changes
- Tested steps with a new AWS Account.
- Removed reference to specific language since they changed the call to action.  Also removed screenshot as it was outdated.

### Create an IAM User
#### Changes
- Updated chapter instructions & screenshots.
- Updated screenshots at 1280x783.
- Screenshots located in `create-iam-user`
- Left old screenshots in `iam-user` for other languages as I couldn't update them to match the new instructions.

### Configure the AWS CLI
#### Changes
- Tested steps with a clean install on Mac.
#### Notes
- [ ] Consider adding [Chocolatey](https://chocolatey.org/) [instructions for Windows](https://discourse.sst.dev/t/configure-the-aws-cli/86/3?u=christinep2.
- [ ] (Consider adding instructions for *NIX flavors.)[https://discourse.sst.dev/t/configure-the-aws-cli/86/5?u=christinep2]
- [ ] Consider adding a link to the AWS instructions instead, in case that is easier.

### What is SST?
#### Changes
- Removed link to other chapters as it encourages skipping the current document
- Added links for the specific IDE Instructions
#### Notes
- [ ] Consider removing the penultimate sentence regarding the alternative guide since it is archived.

### What is Infrastructure as Code?
#### Changes
- Added "using CDK" into the first sentence based on the confusion mentioned in the chapter comments

### What is AWS CDK?
#### Changes
- Changed references to pnpm
- Added question mark to title to match the other titles in the section and the title of the comments page.

### Create an SST app
#### Changes
- updated to pnpm

#### Notes
- [ ] Need to update Next Steps command line output as follows
  - cd notes
  - pnpm add (or npm, or yarn)
  - pnpm exec sst dev

### Create a Hello World API
#### Changes
- updated to pnpm
- Added instructions for Safari et. al. users found in [this discord thread](https://discord.com/channels/983865673656705025/1102040862143303751/1102073623516282890) 

#### Notes
- [ ] Safari instructions for mkcert usage are not working.  Need to investigate further. 

### Initialize a Github Repo
_no specific changes_

### Create a DynamoDB Table in SST
#### Changes
- updated to pnpm
- updated to typescript
- Added clarification as specified in comment

#### Questions
1. Regarding the statement "There’s no specific reason why we are creating a separate stack for these resources." Would it be fair to say that the decision to have separate stacks increases application maintainability?  It seems like it could fall under the principle of "separation of concerns".
2. Why is the Hello World API still present in console after this step?

### Create a S3 Bucket in SST
#### Changes
- updated to pnpm
- updated to typescript
- small wording changes
- moved bucket in return to above table instead of below, matching location in the stack file and alphabetically ordered.
- git commit as a one line command to facilitate using the copy option for the code.

### Review Our App Architecture
_no specific changes_

### Add an API to Create a Note
#### Changes
- updated to pnpm
- updated to typescript
- Added info about DRYness and maintainability to the refactor section.

#### Notes
- Should we uninstall the aws-sdk (or @aws-sdk) from functions when we install it into core?
- Should the user re-test after the refactor to ensure it still works?
- Do we need to add [this note](https://discourse.sst.dev/t/add-an-api-to-create-a-note/2451/18?u=christinep2) for Windows users into the guide?
- Referenced [this error handling blog post](https://kentcdodds.com/blog/get-a-catch-block-error-message-with-typescript) for the error code in handler. 
- I'm seeing a delay as I add the API endpoints with seeing them in the console.  I experienced on two different run-throughs, is this expected? If so, can we add a note to that effect at this point so people don't try and debug? 

### Add an API to Get/Put/Patch/Delete a Note
#### Changes
- updated to pnpm
- updated to typescript

### Adding Auth to Our Serverless App
#### Changes
- Updated to typescript
- Updated to use docs variable instead of hardcoded url

### Secure Our Serverless APIs
#### Changes
- Updated to typescript
- Switched to PNPM
- Used optional chaining operator for `requestContext.authorizer`. Should we have a different solution?
 
### Setup a Stripe Account
#### Changes
- Redo screenshots and update text to match new UI 

### Handling Secrets in SST
#### Changes
- Rewrite to use the SST Secrets CLI based on the information found here: https://docs.sst.dev/config#should-i-use-configsecret-or-env-for-secrets

### Add an API to Handle Billing
#### Changes
- Updated to typescript
- Switched to PNPM

#### Notes
- [ ] Consider not using [nested ternary operators](https://medium.com/@benlmsc/stop-using-nested-ternary-operators-heres-why-53e7e078e65a).

### Unit Tests in Serverless
#### Changes
- Switch to Typescript for testing
- Switch to PNPM
- Add instructions to add Vite Test to workspace

#### Notes
- [ ] Consider including tests as we build out the API instead of at the end, or at least adding a note that this is a preferred approach for ensuring properly tested code.

### Handle CORS in Serverless APIs
#### Changes
- Switch to Typescript
- Switch to PNPM

### Handle CORS in S3 for File Uploads
#### Changes
- Switch to Typescript
- Switch to PNPM

### Create a New React.js App
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

#### Notes
- [ ] Need to [replace create-react-app with one of the recommended solutions](https://github.com/facebook/create-react-app/issues/13072) as create-react-app is being deprecated.
- [ ] Consider adding tests alongside new code from this point forward.

### Set up Custom Fonts
#### Changes
- Minor wording changes
- Update final screenshot to show tsx file instead of js file

### Set up Bootstrap
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Handle Routes with React Router
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Create Containers
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Adding Links in the Navbar
#### Changes
- Switch to PNPM
- Switch to Typescript
- Minor wording changes

### Handle 404s
#### Changes
- Switch to Typescript
- Minor wording changes

### Configure AWS Amplify
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Create a Login Page
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Login with AWS Cognito
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Add the Session to the State
#### Changes
- Switch to Typescript

### Load the State from the Session
#### Changes
- Switch to Typescript
- Move import of UseEffect above explainer so that consumer is not sidetracked by the import not being present.

### Clear the Session on Logout
#### Changes
- Switch to Typescript

### Redirect on Login and Logout
#### Changes
- Switch to Typescript

### Give Feedback While Logging In
#### Changes
- Switch to Typescript

### Create a Custom React Hook to Handle Form Fields
#### Changes
- Switch to Typescript

### Create a Signup Page
No Changes

### Create the Signup Form
#### Changes
- Switch to Typescript
- Minor wording changes

### Signup with AWS Cognito
#### Changes
- Switch to Typescript
- Minor wording changes
### Notes
- [ ] Do we want to add the handling for UserExists in? https://discourse.sst.dev/t/signup-with-aws-cognito/130/74?u=christinep2

### Add the Create Note Page
#### Changes
- Switch to Typescript
- Minor wording changes

### Call the Create API
#### Changes
- Switch to Typescript
- Minor wording changes

### Upload a File to S3
#### Changes
- Switch to Typescript

### Upload a File to S3
#### Changes
- Switch to Typescript
- Added helpful note from @sometimescasey

#### Notes
- [ ] Update troubleshooting tips if outdated.

### List All the Notes
#### Changes
- Switch to Typescript
- Minor wording changes

### Call the List API
#### Changes
- Switch to Typescript
- Move Import immediately after adding code so consumer is not distracted by errors

### Display a Note
#### Changes
- Switch to Typescript

### Render the Note Form
#### Changes
- Switch to Typescript
- Minor wording changes
- Move Import immediately after adding code so consumer is not distracted by errors

### Save Changes to a Note
#### Changes
- Switch to Typescript
- Minor wording changes

### Delete a Note
#### Changes
- Switch to Typescript
- Minor wording changes

### Create a Settings Page
#### Changes
- Switch to Typescript
- Minor wording changes

### Add Stripe Keys to Config
#### Changes
- Switch to Typescript
- Switch to PNPM
- Minor wording changes

### Create a Billing Form
#### Changes
- Switch to Typescript
- Switch to PNPM

### Connect the Billing Form
#### Changes
- Switch to Typescript
- Switch to PNPM

### Set up Secure Pages
No Changes

### Create a Route That Redirects
#### Changes 
- Switch to Typescript

### Use the Redirect Routes
#### Changes
- Switch to Typescript

### Redirect on Login
#### Changes
- Switch to Typescript

### Purchase a Domain with Route 53
Skipped.

### Custom Domains in serverless APIs
#### Changes
- Switch to Typescript
- Minor wording changes

### Custom Domains for React Apps on AWS
#### Changes
- Switch to Typescript/PNPM
- Minor wording changes

#### Notes
- [ ] I tried switching the domain and the alias so that I could easily remove the domain alias and use it for my "real" app and leave the subdomain for this demo, but it erred with the message. 
    ```
      Error: Validation failed with the following errors:
      [prod-notes-FrontendStack/ReactSite/Redirect/RedirectCertificate] DNS zone www-notes.manuals4life.com is not authoritative for certificate domain name manuals4life.com
    ```
    In orde to keep the statement "You can switch these around so that the root domain redirects to the `www.` version as well.", I believe we'd need additional information dealing with the CAA record or whatever tripped it up. 

### Getting Production Ready
No Changes

### Creating a CI/CD Pipeline for serverless
No Changes (other than the global new tab for external links)

### Setting up Your Project on Seed 
#### Changes
- Switch References to Typescript
- Minor wording changes
#### Notes
- [ ] Needs new Screenshots using serverless-stack demo notes app.
- [ ] Might add a screenshot pointing at settings in the UI?

### Configure Secrets in Seed
#### Changes
- Switch References to sst secret instead of .env.local
- Minor wording changes

### Deploying Through Seed
#### Changes
- minor wording changes

### Debugging Full-Stack Serverless Apps
No Changes

### Setup Error Reporting in React
#### Changes
- Switch to Typescript
- Switched to `pnpm add @sentry/react` from `@sentry/browser`
- Added an ErrorInfoType

#### Notes
- [ ] Needs new Screenshots 

### Report API Errors in React
#### Changes
- Switch to Typescript

### Setup an Error Boundary in React
#### Changes
- Switch to Typescript
- Change multiline ternary to if/else
- Updated screenshot for react error
#### Notes
- [ ] Needs new Screenshots for Sentry confirmations

### Setup Error Logging in Serverless
#### Changes
- Switch to Typescript

### Logic Errors in Lambda Functions
#### Changes
- Switch to Typescript
#### Notes
- [ ] Logging extra information is incorrectly displaying `[object Object]`

### Unexpected Errors in Lambda Functions
#### Changes
- Switch references to Typescript

### Errors Outside Lambda Functions
#### Changes
- Switch references to Typescript

### Errors in API Gateway
#### Changes
- Switch references to Typescript

### Wrapping Up
#### Changes
- Switch references to PNPM


## Additional Guide Information Pages still in use:

### Auth In Serverless Apps
#### Changes
- Updated to typescript
- Updated referenced pages What is IAM and What is an ARN

### What is IAM / What is an ARN
#### Changes
- Updated text to remove wording implying it is a step in the guide

### Mapping Cognito Identity Id and User Pool Id

### Cognito User Pool vs Identity Pool

### Setting serverless environment variables in a React app
- Updated to pnpm
- Updated to typescript


## Outstanding Changes

### Extra Credit series of chapters on user management
- [ ] TODO: Update these as they are referenced from "Give Feedback While Logging In" (Specifically links to http://localhost:4000/chapters/manage-user-accounts-in-aws-amplify.html)
