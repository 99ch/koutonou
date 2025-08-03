# 🔧 GitHub Actions Configuration

# Ce fichier documente les secrets et variables d'environnement
# nécessaires pour le bon fonctionnement des workflows CI/CD

## 📋 Repository Secrets Required

### 🤖 Android Deployment
- `ANDROID_KEYSTORE`: Base64 encoded keystore file for Android signing
- `ANDROID_KEYSTORE_PASSWORD`: Password for the Android keystore
- `ANDROID_KEY_PASSWORD`: Password for the Android signing key
- `ANDROID_KEY_ALIAS`: Alias for the Android signing key
- `GOOGLE_PLAY_SERVICE_ACCOUNT`: Google Play Console service account JSON

### 🍎 iOS Deployment
- `IOS_CERTIFICATE`: Base64 encoded iOS distribution certificate (.p12)
- `IOS_CERTIFICATE_PASSWORD`: Password for the iOS certificate
- `IOS_PROVISIONING_PROFILE`: Base64 encoded provisioning profile
- `IOS_KEYCHAIN_PASSWORD`: Password for the temporary keychain
- `APPSTORE_USERNAME`: Apple ID for App Store Connect
- `APPSTORE_PASSWORD`: App-specific password for App Store Connect

### 🌐 Web Deployment
- `NETLIFY_AUTH_TOKEN`: (Optional) Netlify authentication token
- `VERCEL_TOKEN`: (Optional) Vercel authentication token
- `FIREBASE_TOKEN`: (Optional) Firebase authentication token

### 📧 Notifications
- `SLACK_WEBHOOK_URL`: (Optional) Slack webhook for deployment notifications
- `DISCORD_WEBHOOK_URL`: (Optional) Discord webhook for notifications

## 🔐 How to Set Up Secrets

1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add each secret with the exact name listed above

## ⚙️ Environment Configuration

### 🌍 Environments
- `staging`: For development and testing deployments
- `production`: For production deployments

### 🛡️ Protection Rules
- Production environment should require manual approval
- Staging environment can be automatic

## 📱 Platform-Specific Setup

### Android Setup
1. Generate a keystore file:
   ```bash
   keytool -genkey -v -keystore koutonou-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias koutonou
   ```
2. Convert to base64:
   ```bash
   base64 -i koutonou-key.jks | pbcopy
   ```
3. Add to `ANDROID_KEYSTORE` secret

### iOS Setup
1. Export your distribution certificate as .p12
2. Convert to base64:
   ```bash
   base64 -i distribution.p12 | pbcopy
   ```
3. Export your provisioning profile
4. Convert to base64:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

### Google Play Console Setup
1. Create a service account in Google Cloud Console
2. Enable Google Play Console API
3. Download the JSON key file
4. Add the JSON content to `GOOGLE_PLAY_SERVICE_ACCOUNT` secret

## 🚀 Workflow Triggers

### Main CI/CD (`ci-cd.yml`)
- Push to `main`, `production_ready`, `develop`
- Pull requests to `main`, `production_ready`
- Manual trigger

### PR Validation (`pr-validation.yml`)
- Pull requests to any protected branch
- Validates code quality, tests, and builds

### Security (`security.yml`)
- Weekly scheduled run (Mondays at 9 AM UTC)
- Push to main branches when dependencies change
- Manual trigger

### Deployment (`deployment.yml`)
- Release published
- Manual trigger with environment selection

## 📊 Monitoring and Reporting

### 📈 Coverage Reports
- Uploaded to Codecov
- Minimum coverage threshold: 70%

### 🔒 Security Scanning
- Trivy vulnerability scanner
- SARIF reports uploaded to GitHub Security tab

### 📋 Test Reports
- Flutter test results in JSON format
- Uploaded as workflow artifacts

## 🔧 Maintenance

### 🔄 Regular Updates
- Flutter version updated monthly
- Dependencies updated weekly (automated)
- Workflow improvements as needed

### 📅 Review Schedule
- Monthly review of workflow performance
- Quarterly security audit
- Annual infrastructure review

## 🆘 Troubleshooting

### Common Issues
1. **Build Failures**: Check Flutter version compatibility
2. **Test Failures**: Ensure all dependencies are properly mocked
3. **Deployment Failures**: Verify secrets are correctly configured
4. **Coverage Issues**: Add tests for uncovered code paths

### Debug Steps
1. Check workflow logs in GitHub Actions tab
2. Verify all required secrets are set
3. Test locally with same Flutter version
4. Check for breaking changes in dependencies

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)
