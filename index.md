---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

# Table of Contents

- [Create a new app with Create React App]({{ site.baseurl }}{% link _chapters/create-new-create-react-app.md %})
  - [Add favicons]({{ site.baseurl }}{% link _chapters/add-favicons.md %})
  - [Include custom fonts]({{ site.baseurl }}{% link _chapters/include-custom-fonts.md %})
  - [Setting up Bootstrap]({{ site.baseurl }}{% link _chapters/setting-up-bootstrap.md %})
- Create routes with React Router
  - Create containers
  - Handle 404s
- Create a login form
  - Form controls with Bootstrap
  - Use React controller components to handle state
  - Validate form fields before submitting
- [Coming soon...]
- Deploy
  - Create a S3 bucket
  - Upload to S3
  - Create a CloudFront distribution
  - Point your domain to CloudFront
  - Setup SSL
- Re-deploy
  - Sync local with S3
  - Invalidate CloudFront
- Staging and Rollbacks
  - Staging environment with S3
  - Promoting to production
  - Rolling back deploys
