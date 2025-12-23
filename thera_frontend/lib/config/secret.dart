// WARNING: This file contains an API key in plaintext.
// For production, prefer storing secrets in secure storage or using
// runtime configuration (CI/CD secrets, --dart-define, etc.).

// Google AI Studio / Gemini API key
const String FALLBACK_AI_API_KEY = 'AIzaSyD7lKIqO9Qmhzm4aQ-iOLVwALoUCGQCdmE';

// Gemini REST endpoint (key is provided as a query param)
const String FALLBACK_AI_URL =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
