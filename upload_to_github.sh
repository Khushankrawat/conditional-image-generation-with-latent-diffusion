#!/bin/bash

# GitHub Upload Script for AI Face Generator
# This script helps upload updates to the GitHub repository

echo "🚀 Uploading AI Face Generator to GitHub"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -f "api.py" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Add all changes
echo "📝 Adding changes to Git..."
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
else
    # Commit changes
    echo "💾 Committing changes..."
    read -p "Enter commit message (or press Enter for default): " commit_message
    if [ -z "$commit_message" ]; then
        commit_message="Update AI Face Generator project"
    fi
    git commit -m "$commit_message"
    
    # Push to GitHub
    echo "🌐 Pushing to GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully uploaded to GitHub!"
        echo "🔗 Repository: https://github.com/Khushankrawat/conditional-image-generation"
    else
        echo "❌ Failed to push to GitHub. Please check your connection and try again."
        exit 1
    fi
fi

echo "🎉 Upload complete!"
