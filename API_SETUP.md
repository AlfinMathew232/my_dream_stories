# API Setup Guide

This guide provides step-by-step instructions for obtaining the required API keys for the My Dream Stories app.

## Overview

The app requires two main API services:
1. **Google Gemini API** - For AI story generation AND video generation (Veo 3.1)
2. **Razorpay** - For payment processing

---

## 1. Google Gemini API Setup (Required)

Google's Gemini API provides both AI story generation and video generation capabilities through the Veo 3.1 Fast model.

### Steps:

1. **Get Gemini API Key(s)**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Click "Get API key" or "Create API key"
   - Select your Google Cloud project (or create a new one)
   - Copy the generated API key
   
   **Option 1: Single Key (Simpler)**
   - Use the same API key for both prompt generation and video generation
   - Easier to manage but shares quota between both services
   
   **Option 2: Separate Keys (Better Quota Management)**
   - Create two separate API keys:
     - One for prompt/story generation
     - One for video generation (Veo 3.1)
   - Better quota isolation and monitoring
   - Recommended for production use

2. **Add the API Key(s) to your app**
   - Open `lib/api_keys.dart`
   - Replace `YOUR_GEMINI_PROMPT_KEY_HERE` with your prompt generation key
   - Replace `YOUR_GEMINI_VIDEO_KEY_HERE` with your video generation key
   - (Or use the same key for both if you chose Option 1)

**Pricing**: Free tier includes 60 requests per minute. See [pricing details](https://ai.google.dev/pricing).

**What it's used for**:
- **Story Generation**: Uses Gemini Pro model to enhance and create stories from user prompts
- **Video Generation**: Uses Veo 3.1 Fast model to generate videos from text descriptions

### Veo 3.1 Fast Model

The Veo 3.1 Fast model is Google's latest video generation AI that creates high-quality videos from text prompts.

**API Endpoint**: 
```
https://generativelanguage.googleapis.com/v1beta/models/veo-3.1-fast-generate-preview:predictLongRunning
```

**Features**:
- Fast video generation (typically 30-120 seconds)
- High-quality output
- Text-to-video capabilities
- Supports various aspect ratios (16:9, 9:16, 1:1)

**How it works**:
1. Submit a text prompt describing the video you want
2. Receive an operation name (e.g., "operations/abc123")
3. Poll the operation status until completion
4. Download the generated video using the provided URI

**Example Request** (handled by `veo_service.dart`):
```bash
curl "${BASE_URL}/models/veo-3.1-fast-generate-preview:predictLongRunning" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -X "POST" \
  -d '{
    "instances": [{
        "prompt": "A close up of two people staring at a cryptic drawing on a wall"
      }
    ]
  }'
```

**Response**:
```json
{
  "name": "operations/abc123xyz"
}
```

**Polling for Status**:
```bash
curl "${BASE_URL}/operations/abc123xyz" \
  -H "x-goog-api-key: YOUR_API_KEY"
```

**Completed Response**:
```json
{
  "done": true,
  "response": {
    "videoSamples": [{
      "videoUri": "https://generativelanguage.googleapis.com/v1beta/files/xyz/video.mp4"
    }]
  }
}
```

---

## 2. Razorpay Setup (Required for Payments)

Razorpay provides payment processing capabilities for premium features.

### Steps:

1. **Create a Razorpay Account**
   - Visit [Razorpay Dashboard](https://dashboard.razorpay.com/)
   - Sign up for an account
   - Complete KYC verification (for live mode)

2. **Get API Keys**
   - Go to Settings → API Keys
   - Generate Test Mode keys for development
   - Copy the Key ID (starts with `rzp_test_`)

3. **Add the API Key to your app**
   - Open `lib/api_keys.dart`
   - Replace `YOUR_RAZORPAY_KEY_ID_HERE` with your key

**Pricing**: 
- Test mode is free
- Live mode has transaction fees (typically 2% + ₹0)
- See [pricing details](https://razorpay.com/pricing/)

**Important Notes**:
- Use Test mode during development
- Switch to Live mode only when ready for production
- Never commit API keys to version control

---

## Configuration

After obtaining your API keys, configure them in your app:

1. **Open the API keys file**:
   ```
   lib/api_keys.dart
   ```

2. **Replace the placeholder values**:
   ```dart
   class ApiKeys {
     // Google Gemini API Key
     // Used for both AI story generation AND video generation (Veo 3.1)
     static const String geminiApiKey = "YOUR_ACTUAL_GEMINI_KEY_HERE";
     
     // Razorpay Test Key
     static const String razorpayKeyId = "rzp_test_YOUR_ACTUAL_KEY_HERE";
     
     // Optional: OpenAI API Key (if you want to use GPT for story generation)
     static const String openAiApiKey = "YOUR_OPENAI_KEY_HERE";
   }
   ```

3. **Verify configuration**:
   - Run the app and test story generation
   - Test video generation with a simple prompt
   - Verify that API calls are successful

---

## Security Best Practices

1. **Never commit API keys to version control**
   - The `api_keys.dart` file is already in `.gitignore`
   - Always use the example file to track config structure

2. **Use environment variables** (for production):
   - Consider using Flutter dotenv or similar packages
   - Load keys from environment variables in production builds

3. **Restrict API keys**:
   - Add API restrictions in Google Cloud Console
   - Add IP restrictions if possible
   - Set usage limits to prevent unexpected charges

4. **Monitor usage**:
   - Regularly check your API usage in Google AI Studio
   - Check Razorpay dashboard for payment activity
   - Set up billing alerts to avoid unexpected charges

5. **Rotate keys regularly**:
   - Change API keys periodically
   - Immediately rotate if a key is accidentally exposed

---

## Cost Optimization Tips

1. **Use free tiers wisely**:
   - Google Gemini offers generous free tier for both story and video generation
   - Monitor your usage to stay within free tier limits

2. **Cache results**:
   - Store generated stories to avoid regenerating the same content
   - Cache video generation results when possible

3. **Optimize prompts**:
   - Use clear, concise prompts to reduce generation time
   - Test prompts to ensure they produce desired results

4. **Monitor video generation**:
   - Video generation can be resource-intensive
   - Consider implementing rate limiting for users
   - Track generation costs and adjust pricing accordingly

---

## Troubleshooting

### Common Issues:

1. **"API key invalid" error**:
   - Double-check you copied the entire key
   - Ensure no extra spaces or characters
   - Verify the key hasn't been deleted or restricted

2. **"Quota exceeded" error**:
   - Check your usage limits in Google AI Studio
   - Upgrade your plan or wait for quota reset
   - Consider implementing rate limiting

3. **"Billing not enabled" error**:
   - Some services require billing to be set up
   - Add a payment method even if using free tier

4. **Video generation timeout**:
   - Veo 3.1 Fast typically takes 30-120 seconds
   - Implement appropriate timeout handling (2-3 minutes)
   - Check operation status regularly (every 10 seconds)

5. **Video URI not found**:
   - Ensure the operation is marked as "done"
   - Check both possible URI locations in the response
   - Verify API key has proper permissions

---

## Alternative Services (Optional)

If you want to use different services:

### For Story Generation:
- **OpenAI GPT**: https://platform.openai.com/
- **Anthropic Claude**: https://www.anthropic.com/api
- **Cohere**: https://cohere.ai/

### For Video Generation:
- **Runway ML**: https://runwayml.com/ (previous service)
- **Stability AI**: https://platform.stability.ai/
- **D-ID**: https://www.d-id.com/

**Note**: Using alternative services will require code modifications in the respective service files.

---

## Need Help?

If you encounter issues:
- Check the official [Google AI documentation](https://ai.google.dev/docs)
- Review [Razorpay documentation](https://razorpay.com/docs/)
- Review error messages carefully
- Contact the provider's support team
- Ask in relevant developer communities

---

## Next Steps

Once you have configured all API keys:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app and test story generation
4. Test video generation with a simple prompt
5. Monitor API usage and costs

Happy building! 🚀
