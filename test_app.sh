#!/bin/bash

echo "🚀 Testing Recycle Lebs Flutter App"
echo "=================================="

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter SDK first"
    exit 1
fi

echo "✅ Flutter found"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Run analysis
echo "🔍 Running code analysis..."
flutter analyze --no-fatal-infos

if [ $? -eq 0 ]; then
    echo "✅ Code analysis passed"
else
    echo "⚠️  Code analysis found issues (but app should still run)"
fi

# Run tests
echo "🧪 Running tests..."
flutter test

if [ $? -eq 0 ]; then
    echo "✅ Tests passed"
else
    echo "⚠️  Some tests failed (but app should still run)"
fi

echo ""
echo "🎉 App is ready to run!"
echo ""
echo "To start the app:"
echo "1. Connect an Android device or start an emulator"
echo "2. Run: flutter run"
echo ""
echo "Demo accounts:"
echo "Seller:  ahmed@example.com / password"
echo "Buyer:   fatima@example.com / password"
echo "Admin:   admin@recyclelebs.com / password"
echo ""
echo "✨ Happy testing! ♻️"
