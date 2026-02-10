# API Setup Guide

This guide provides step-by-step instructions for obtaining the required API keys for the My Dream Stories app.

## Overview

The app requires three types of API keys:
1. **Speech-to-Text** - For converting voice narration to text
2. **Story Generation** - For creating stories from text prompts
3. **Text+Image to Video** - For generating videos from text descriptions and images

---

## 1. Speech-to-Text API Setup

### Option A: Google Cloud Speech-to-Text (Recommended)

Google Cloud Speech-to-Text provides high-quality speech recognition with support for multiple languages.

#### Steps:

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Click "Select a project" → "New Project"
   - Enter a project name (e.g., "my-dream-stories")
   - Click "Create"

2. **Enable the Speech-to-Text API**
   - In the Google Cloud Console, go to [APIs & Services > Library](https://console.cloud.google.com/apis/library)
   - Search for "Speech-to-Text API"
   - Click on it and press "Enable"

3. **Create API Credentials**
   - Go to [APIs & Services > Credentials](https://console.cloud.google.com/apis/credentials)
   - Click "Create Credentials" → "API key"
   - Copy the generated API key
   - **(Important)** Click "Restrict Key" to add restrictions:
     - Under "API restrictions", select "Restrict key"
     - Choose "Cloud Speech-to-Text API"
     - Click "Save"

4. **Set up Billing**
   - Speech-to-Text requires a billing account
   - Go to [Billing](https://console.cloud.google.com/billing)
   - Link a billing account (Google offers free credits for new users)

5. **Add the API Key to your app**
   - Open `lib/config/api_config.dart`
   - Replace `YOUR_SPEECH_TO_TEXT_API_KEY_HERE` with your API key

**Pricing**: Free tier includes 60 minutes per month. See [pricing details](https://cloud.google.com/speech-to-text/pricing).

### Option B: Alternative Services

- **Azure Speech Services**: https://azure.microsoft.com/en-us/services/cognitive-services/speech-to-text/
- **Amazon Transcribe**: https://aws.amazon.com/transcribe/
- **AssemblyAI**: https://www.assemblyai.com/

---

## 2. Story Generation API Setup

### Option A: Google Gemini API (Recommended for Free Tier)

Google's Gemini AI offers generous free tier and excellent story generation capabilities.

#### Steps:

1. **Get a Gemini API Key**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Click "Get API key" or "Create API key"
   - Select your Google Cloud project (or create a new one)
   - Copy the generated API key

2. **Add the API Key to your app**
   - Open `lib/config/api_config.dart`
   - Replace `YOUR_STORY_GENERATION_API_KEY_HERE` with your API key

**Pricing**: Free tier includes 60 requests per minute. See [pricing details](https://ai.google.dev/pricing).

**API Endpoint**: Update the endpoint in `api_config.dart`:
```dart
static const String storyGenerationEndpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';
```

### Option B: OpenAI GPT

OpenAI's GPT models are excellent for creative story generation.

#### Steps:

1. **Create an OpenAI Account**
   - Go to [OpenAI Platform](https://platform.openai.com/)
   - Sign up or log in

2. **Add Payment Method**
   - Go to [Billing](https://platform.openai.com/account/billing)
   - Add a payment method (required for API access)

3. **Create an API Key**
   - Go to [API Keys](https://platform.openai.com/api-keys)
   - Click "Create new secret key"
   - Give it a name (e.g., "my-dream-stories")
   - Copy the API key immediately (it won't be shown again)

4. **Add the API Key to your app**
   - Open `lib/config/api_config.dart`
   - Replace `YOUR_STORY_GENERATION_API_KEY_HERE` with your API key

**Pricing**: Pay-as-you-go. GPT-3.5-Turbo is more affordable, GPT-4 is more capable. See [pricing details](https://openai.com/pricing).

### Option C: Other Alternatives

- **Anthropic Claude**: https://www.anthropic.com/api
- **Cohere**: https://cohere.ai/
- **Hugging Face**: https://huggingface.co/inference-api

---

## 3. Text+Image to Video API Setup

### Option A: Runway ML

Runway ML offers AI-powered video generation from text and images.

#### Steps:

1. **Create a Runway Account**
   - Go to [Runway ML](https://runwayml.com/)
   - Sign up for an account

2. **Subscribe to a Plan**
   - Runway requires a subscription for API access
   - Go to [Pricing](https://runwayml.com/pricing)
   - Choose a plan (Standard or Pro)

3. **Get Your API Key**
   - Log in to your Runway account
   - Go to [API Settings](https://app.runwayml.com/settings/api)
   - Generate an API key
   - Copy the API key

4. **Add the API Key to your app**
   - Open `lib/config/api_config.dart`
   - Replace `YOUR_TEXT_IMAGE_TO_VIDEO_API_KEY_HERE` with your API key

**Pricing**: Starts at $12/month. Includes credits for video generation. See [pricing details](https://runwayml.com/pricing).

### Option B: Stability AI

Stability AI (makers of Stable Diffusion) also offers video generation capabilities.

#### Steps:

1. **Get a Stability AI API Key**
   - Go to [Stability AI Platform](https://platform.stability.ai/)
   - Sign up or log in
   - Go to [API Keys](https://platform.stability.ai/account/keys)
   - Generate a new API key
   - Copy the key

2. **Add the API Key to your app**
   - Open `lib/config/api_config.dart`
   - Replace `YOUR_TEXT_IMAGE_TO_VIDEO_API_KEY_HERE` with your API key

**Pricing**: Pay-as-you-go with credits. See [pricing details](https://platform.stability.ai/pricing).

**API Endpoint**: Update the endpoint in `api_config.dart`:
```dart
static const String textImageToVideoEndpoint = 'https://api.stability.ai/v2alpha/generation/text-to-video';
```

### Option C: Other Alternatives

- **D-ID**: https://www.d-id.com/ (Talking head videos)
- **Synthesia**: https://www.synthesia.io/ (AI video generation)
- **Pictory AI**: https://pictory.ai/ (Text to video)

---

## Configuration

After obtaining your API keys, configure them in your app:

1. **Open the API config file**:
   ```
   lib/config/api_config.dart
   ```

2. **Replace the placeholder values**:
   ```dart
   static const String speechToTextApiKey = 'your-actual-key-here';
   static const String storyGenerationApiKey = 'your-actual-key-here';
   static const String textImageToVideoApiKey = 'your-actual-key-here';
   ```

3. **Update endpoints if needed**:
   - The default endpoints are set for Google Cloud Speech-to-Text, OpenAI GPT, and Runway ML
   - If using different providers, update the endpoint URLs accordingly

4. **Verify configuration**:
   - The app includes helper methods to check if keys are configured
   - Use `ApiConfig.areApiKeysConfigured` to check status
   - Use `ApiConfig.getValidationErrors()` to see which keys are missing

---

## Security Best Practices

1. **Never commit API keys to version control**
   - The `api_config.dart` file is already in `.gitignore`
   - Always use the example file to track config structure

2. **Use environment variables** (for production):
   - Consider using Flutter dotenv or similar packages
   - Load keys from environment variables in production builds

3. **Restrict API keys**:
   - Add API restrictions in Google Cloud Console
   - Add IP restrictions if possible
   - Set usage limits to prevent unexpected charges

4. **Monitor usage**:
   - Regularly check your API usage in each provider's console
   - Set up billing alerts to avoid unexpected charges

5. **Rotate keys regularly**:
   - Change API keys periodically
   - Immediately rotate if a key is accidentally exposed

---

## Cost Optimization Tips

1. **Use free tiers wisely**:
   - Google Gemini offers generous free tier for story generation
   - Google Speech-to-Text offers 60 minutes free per month

2. **Cache results**:
   - Store generated stories to avoid regenerating the same content
   - Cache speech-to-text results

3. **Batch requests**:
   - Combine multiple requests when possible
   - Some providers offer discounts for bulk usage

4. **Choose appropriate models**:
   - Use GPT-3.5-Turbo instead of GPT-4 for cost savings
   - Use smaller models when high quality isn't critical

---

## Troubleshooting

### Common Issues:

1. **"API key invalid" error**:
   - Double-check you copied the entire key
   - Ensure no extra spaces or characters
   - Verify the key hasn't been deleted or restricted

2. **"Quota exceeded" error**:
   - Check your usage limits in the provider's console
   - Upgrade your plan or wait for quota reset

3. **"Billing not enabled" error**:
   - Some services require billing to be set up
   - Add a payment method even if using free tier

4. **Request timeout**:
   - Video generation can take time
   - Implement appropriate timeout handling in your app
   - Consider using webhooks for long-running operations

---

## Need Help?

If you encounter issues:
- Check the official documentation for each API provider
- Review error messages carefully
- Contact the provider's support team
- Ask in relevant developer communities

---

## Next Steps

Once you have configured all API keys:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app and test each feature
4. Monitor API usage and costs

Happy building! 🚀
