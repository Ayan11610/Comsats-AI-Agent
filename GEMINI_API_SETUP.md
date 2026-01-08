# Gemini API Setup and Quota Management Guide

## Overview
This guide helps you set up and manage your Google Gemini API key for the COMSATS GPT application.

## Getting a New API Key

### Step 1: Visit Google AI Studio
1. Go to [https://ai.google.dev/](https://ai.google.dev/)
2. Click on "Get API Key" or "Get Started"
3. Sign in with your Google account

### Step 2: Create API Key
1. Navigate to "Get API Key" in Google AI Studio
2. Click "Create API Key"
3. Select or create a Google Cloud project
4. Copy the generated API key

### Step 3: Update Your Application
1. Open the `.env` file in your project root
2. Replace the existing `GEMINI_API_KEY` value with your new key:
   ```
   GEMINI_API_KEY=your_new_api_key_here
   ```
3. Save the file
4. Restart the application

## Understanding Quota Limits

### Free Tier Limits (as of 2024)
- **Requests per minute (RPM)**: 15
- **Requests per day (RPD)**: 1,500
- **Tokens per minute (TPM)**: 1 million
- **Tokens per day**: 50 million

### What Causes Quota Exceeded Errors?
1. **Too many requests**: Sending messages too frequently
2. **Daily limit reached**: Exceeded 1,500 requests in 24 hours
3. **Token limit**: Processing too much text in a short time
4. **Multiple users**: If sharing the same API key across devices

## Solutions for Quota Issues

### Immediate Solutions
1. **Wait for Reset**: Quotas reset after 24 hours
2. **Get New API Key**: Create a new key with a different Google account
3. **Use Multiple Keys**: Rotate between different API keys
4. **Reduce Usage**: Limit the number of requests

### Long-term Solutions
1. **Upgrade to Paid Plan**: 
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Enable billing for your project
   - Get higher rate limits

2. **Optimize Requests**:
   - Reduce `maxOutputTokens` in the configuration
   - Cache responses when possible
   - Implement request throttling

3. **Monitor Usage**:
   - Check usage at [https://ai.dev/rate-limit](https://ai.dev/rate-limit)
   - Track your daily request count
   - Set up alerts for approaching limits

## Error Messages Explained

### "Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests"
- **Meaning**: You've hit the daily request limit (1,500 requests)
- **Solution**: Wait 24 hours or upgrade to paid plan

### "Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_input_token_count"
- **Meaning**: You've processed too many input tokens
- **Solution**: Reduce message length or wait for reset

### "Please retry in X seconds"
- **Meaning**: Rate limit hit (too many requests per minute)
- **Solution**: Wait the specified time before retrying

## Best Practices

### 1. Protect Your API Key
- Never commit `.env` file to version control
- Don't share your API key publicly
- Rotate keys regularly for security

### 2. Optimize Usage
- Keep messages concise
- Avoid unnecessary API calls
- Implement caching for common queries
- Use the knowledge base for static information

### 3. Monitor and Track
- Log API usage in your application
- Set up monitoring for quota limits
- Track error rates and patterns

### 4. Handle Errors Gracefully
- The app now provides user-friendly error messages
- Implement retry logic with exponential backoff
- Provide fallback responses when possible

## Upgrading to Paid Plan

### Benefits
- Higher rate limits (up to 1,000 RPM)
- More tokens per day
- Better reliability
- Priority support

### How to Upgrade
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Enable billing
4. Navigate to "APIs & Services" > "Gemini API"
5. Review and accept pricing
6. Your limits will automatically increase

### Pricing (Check current rates)
- Pay-as-you-go model
- Charged per 1,000 tokens
- Free tier still available for testing
- Visit [https://ai.google.dev/pricing](https://ai.google.dev/pricing) for current rates

## Troubleshooting

### API Key Not Working
1. Verify the key is correct in `.env`
2. Check if the key has proper permissions
3. Ensure the Gemini API is enabled in your Google Cloud project
4. Try generating a new key

### Still Getting Quota Errors
1. Check your usage at [https://ai.dev/rate-limit](https://ai.dev/rate-limit)
2. Verify you're not sharing the key across multiple apps
3. Consider using multiple API keys
4. Upgrade to a paid plan

### Application Not Responding
1. Check your internet connection
2. Verify the API endpoint is accessible
3. Review console logs for detailed errors
4. Restart the application

## Support and Resources

### Official Documentation
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Rate Limits Guide](https://ai.google.dev/gemini-api/docs/rate-limits)
- [Pricing Information](https://ai.google.dev/pricing)

### Monitoring Tools
- [Usage Dashboard](https://ai.dev/rate-limit)
- [Google Cloud Console](https://console.cloud.google.com/)

### Getting Help
- [Google AI Forum](https://discuss.ai.google.dev/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/google-gemini)
- Check the application logs for detailed error messages

## Quick Reference

### Environment Variable
```bash
GEMINI_API_KEY=your_api_key_here
```

### Free Tier Limits
- 15 requests/minute
- 1,500 requests/day
- 1M tokens/minute
- 50M tokens/day

### Important Links
- Get API Key: https://ai.google.dev/
- Monitor Usage: https://ai.dev/rate-limit
- Documentation: https://ai.google.dev/docs
- Pricing: https://ai.google.dev/pricing

---

**Last Updated**: January 2026  
**For**: COMSATS GPT Application
