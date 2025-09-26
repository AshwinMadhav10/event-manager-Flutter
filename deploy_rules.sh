#!/bin/bash

echo "Firebase Firestore Rules Deployment Script"
echo "=========================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ You are not logged in to Firebase. Please run:"
    echo "   firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready"

# List available projects
echo ""
echo "Available Firebase projects:"
firebase projects:list

echo ""
echo "To deploy the Firestore rules, you need to:"
echo "1. Choose one of your existing projects or create a new one"
echo "2. Run: firebase use <project-id>"
echo "3. Run: firebase deploy --only firestore:rules"
echo ""
echo "Or you can run the deployment directly with:"
echo "firebase deploy --only firestore:rules --project <project-id>" 