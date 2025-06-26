#!/bin/bash
echo "🔄 Checking GitHub Actions status..."
echo "📍 Repository: https://github.com/jussimir/n64-music-visualizer"
echo "🔗 Actions URL: https://github.com/jussimir/n64-music-visualizer/actions"
echo "📝 Latest commit: $(git log --oneline -1)"
echo "⏰ Pushed at: $(git log -1 --format=%cd)"
echo ""
echo "💡 Tip: Open the Actions URL above to see live build status!"

