#!/bin/bash

# Notes App - Build and Test Script
# This script helps build and test the Notes application

echo "📱 Notes App - Build and Test Script"
echo "====================================="

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

# Function to build the project
build_project() {
    echo "🔨 Building project..."
    xcodebuild -project Notes.xcodeproj -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' build
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful!"
    else
        echo "❌ Build failed!"
        exit 1
    fi
}

# Function to run unit tests
run_unit_tests() {
    echo "🧪 Running unit tests..."
    xcodebuild -project Notes.xcodeproj -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:NotesTests
    
    if [ $? -eq 0 ]; then
        echo "✅ Unit tests passed!"
    else
        echo "❌ Unit tests failed!"
        exit 1
    fi
}

# Function to run UI tests
run_ui_tests() {
    echo "🎯 Running UI tests..."
    xcodebuild -project Notes.xcodeproj -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:NotesUITests
    
    if [ $? -eq 0 ]; then
        echo "✅ UI tests passed!"
    else
        echo "❌ UI tests failed!"
        exit 1
    fi
}

# Function to run all tests
run_all_tests() {
    echo "🧪 Running all tests..."
    xcodebuild -project Notes.xcodeproj -scheme Notes -destination 'platform=iOS Simulator,name=iPhone 16' test
    
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed!"
    else
        echo "❌ Some tests failed!"
        exit 1
    fi
}

# Function to clean build
clean_build() {
    echo "🧹 Cleaning build..."
    xcodebuild -project Notes.xcodeproj -scheme Notes clean
    echo "✅ Clean completed!"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  build       Build the project"
    echo "  test        Run unit tests only"
    echo "  uitest      Run UI tests only"
    echo "  all         Run all tests"
    echo "  clean       Clean build folder"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 test"
    echo "  $0 all"
}

# Main script logic
case "${1:-help}" in
    "build")
        build_project
        ;;
    "test")
        run_unit_tests
        ;;
    "uitest")
        run_ui_tests
        ;;
    "all")
        build_project
        run_all_tests
        ;;
    "clean")
        clean_build
        ;;
    "help"|*)
        show_help
        ;;
esac

echo ""
echo "🎉 Script completed!"
