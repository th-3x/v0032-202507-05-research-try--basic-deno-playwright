#!/bin/bash

# Deno + Playwright One-Click Setup Script
# This script sets up a complete Deno + Playwright environment

set -e  # Exit on any error

echo "🚀 Starting Deno + Playwright One-Click Setup..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Deno is installed
check_deno() {
    print_info "Checking Deno installation..."
    if command -v deno &> /dev/null; then
        DENO_VERSION=$(deno --version | head -n1)
        print_status "Deno is installed: $DENO_VERSION"
    else
        print_error "Deno is not installed!"
        print_info "Please install Deno first: https://deno.land/manual/getting_started/installation"
        exit 1
    fi
}

# Create project structure
create_project_structure() {
    print_info "Creating project structure..."
    
    # Create directories if they don't exist
    mkdir -p examples
    mkdir -p screenshots
    mkdir -p tests
    
    print_status "Project directories created"
}

# Create deno.json configuration
create_deno_config() {
    print_info "Creating deno.json configuration..."
    
    cat > deno.json << 'EOF'
{
  "tasks": {
    "example": "deno run --allow-net --allow-read --allow-write --allow-run --allow-env --allow-sys examples/basic-example.ts",
    "scrape": "deno run --allow-net --allow-read --allow-write --allow-run --allow-env --allow-sys examples/scraper-example.ts",
    "test": "deno run --allow-net --allow-read --allow-write --allow-run --allow-env --allow-sys tests/test-example.ts",
    "install-browsers": "npx playwright@1.40.0 install",
    "dev": "deno run --allow-net --allow-read --allow-write --allow-run --allow-env --allow-sys --watch"
  },
  "imports": {
    "playwright": "npm:playwright@1.40.0",
    "playwright/": "npm:playwright@1.40.0/"
  },
  "compilerOptions": {
    "allowJs": true,
    "lib": ["deno.window"]
  }
}
EOF
    
    print_status "deno.json created"
}

# Create basic example
create_basic_example() {
    print_info "Creating basic Playwright example..."
    
    cat > examples/basic-example.ts << 'EOF'
import { chromium } from "playwright";

async function basicExample() {
  console.log("🌐 Starting basic Playwright example...");
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  try {
    // Navigate to example.com
    await page.goto("https://example.com");
    
    // Get page title and URL
    const title = await page.title();
    const url = page.url();
    
    console.log(`📄 Page Title: ${title}`);
    console.log(`🔗 URL: ${url}`);
    
    // Take a screenshot
    await page.screenshot({ 
      path: "screenshots/basic-example.png",
      fullPage: true 
    });
    
    // Get page content
    const content = await page.textContent("body");
    console.log(`📝 Page contains ${content?.length || 0} characters`);
    
    print_status("Basic example completed successfully!");
    
  } catch (error) {
    console.error("❌ Error in basic example:", error);
  } finally {
    await browser.close();
  }
}

if (import.meta.main) {
  basicExample().catch(console.error);
}
EOF
    
    print_status "Basic example created"
}

# Create scraper example
create_scraper_example() {
    print_info "Creating web scraper example..."
    
    cat > examples/scraper-example.ts << 'EOF'
import { chromium } from "playwright";

interface NewsItem {
  title: string;
  url: string;
  score?: string;
}

async function scrapeHackerNews(): Promise<NewsItem[]> {
  console.log("🕷️  Starting Hacker News scraper...");
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    await page.goto("https://news.ycombinator.com", { 
      waitUntil: "networkidle" 
    });

    // Wait for content to load
    await page.waitForSelector(".titleline");

    // Extract stories
    const stories = await page.evaluate(() => {
      const items: NewsItem[] = [];
      const rows = document.querySelectorAll("tr.athing");
      
      rows.forEach((row, index) => {
        if (index >= 10) return; // Limit to top 10
        
        const titleElement = row.querySelector(".titleline > a");
        const scoreElement = row.nextElementSibling?.querySelector(".score");
        
        if (titleElement) {
          const title = titleElement.textContent?.trim() || "";
          const href = titleElement.getAttribute("href") || "";
          const url = href.startsWith("http") ? href : `https://news.ycombinator.com/${href}`;
          const score = scoreElement?.textContent || "0 points";
          
          items.push({ title, url, score });
        }
      });
      
      return items;
    });

    // Take screenshot
    await page.screenshot({ 
      path: "screenshots/hackernews-scrape.png",
      fullPage: true 
    });

    console.log("\n📰 Top Hacker News Stories:");
    console.log("=" .repeat(50));
    
    stories.forEach((story, index) => {
      console.log(`${index + 1}. ${story.title}`);
      console.log(`   Score: ${story.score}`);
      console.log(`   URL: ${story.url}`);
      console.log("");
    });

    return stories;
    
  } catch (error) {
    console.error("❌ Scraping error:", error);
    return [];
  } finally {
    await browser.close();
  }
}

if (import.meta.main) {
  scrapeHackerNews().catch(console.error);
}
EOF
    
    print_status "Scraper example created"
}

# Create test example
create_test_example() {
    print_info "Creating automated test example..."
    
    cat > tests/test-example.ts << 'EOF'
import { chromium, Browser, Page } from "playwright";

class PlaywrightTester {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async setup() {
    this.browser = await chromium.launch({ headless: true });
    const context = await this.browser.newContext({
      viewport: { width: 1280, height: 720 }
    });
    this.page = await context.newPage();
  }

  async teardown() {
    if (this.browser) {
      await this.browser.close();
    }
  }

  async testGoogleSearch(): Promise<boolean> {
    if (!this.page) throw new Error("Page not initialized");

    console.log("🔍 Testing Google Search functionality...");
    
    try {
      await this.page.goto("https://www.google.com");
      
      // Handle cookie consent if present
      try {
        await this.page.click('button:has-text("Accept all")', { timeout: 3000 });
      } catch {
        // Cookie banner might not be present
      }

      // Perform search
      await this.page.fill('input[name="q"]', "Deno Playwright automation");
      await this.page.press('input[name="q"]', "Enter");
      
      // Wait for results
      await this.page.waitForSelector("#search", { timeout: 10000 });
      
      // Verify results
      const resultsText = await this.page.textContent("#search");
      const hasResults = resultsText && resultsText.length > 0;
      
      // Take screenshot
      await this.page.screenshot({ 
        path: "screenshots/google-search-test.png" 
      });
      
      console.log(`✅ Google search test: ${hasResults ? "PASSED" : "FAILED"}`);
      return !!hasResults;
      
    } catch (error) {
      console.error("❌ Google search test failed:", error);
      return false;
    }
  }

  async testFormSubmission(): Promise<boolean> {
    if (!this.page) throw new Error("Page not initialized");

    console.log("📝 Testing form submission...");
    
    try {
      await this.page.goto("https://httpbin.org/forms/post");
      
      // Fill form
      await this.page.fill('input[name="custname"]', "Test User");
      await this.page.fill('input[name="custtel"]', "555-0123");
      await this.page.fill('input[name="custemail"]', "test@example.com");
      await this.page.selectOption('select[name="size"]', "large");
      await this.page.check('input[name="topping"][value="cheese"]');
      await this.page.fill('textarea[name="comments"]', "Automated test comment");
      
      // Submit form
      await this.page.click('input[type="submit"]');
      
      // Wait for response
      await this.page.waitForSelector("pre");
      
      // Verify submission
      const responseText = await this.page.textContent("pre");
      const isSuccessful = responseText?.includes("Test User") && 
                          responseText?.includes("test@example.com");
      
      console.log(`✅ Form submission test: ${isSuccessful ? "PASSED" : "FAILED"}`);
      return !!isSuccessful;
      
    } catch (error) {
      console.error("❌ Form submission test failed:", error);
      return false;
    }
  }
}

async function runAllTests() {
  console.log("🧪 Starting Playwright automated tests...");
  console.log("=" .repeat(50));
  
  const tester = new PlaywrightTester();
  const results: { [key: string]: boolean } = {};
  
  try {
    await tester.setup();
    
    results.googleSearch = await tester.testGoogleSearch();
    results.formSubmission = await tester.testFormSubmission();
    
    // Summary
    console.log("\n🎯 Test Results Summary:");
    console.log("=" .repeat(30));
    
    const passed = Object.values(results).filter(Boolean).length;
    const total = Object.keys(results).length;
    
    Object.entries(results).forEach(([test, result]) => {
      console.log(`${result ? "✅" : "❌"} ${test}: ${result ? "PASSED" : "FAILED"}`);
    });
    
    console.log(`\n📊 Overall: ${passed}/${total} tests passed`);
    
    if (passed === total) {
      console.log("🎉 All tests passed!");
    } else {
      console.log("⚠️  Some tests failed. Check the logs above.");
    }
    
  } catch (error) {
    console.error("❌ Test suite failed:", error);
  } finally {
    await tester.teardown();
  }
}

if (import.meta.main) {
  runAllTests().catch(console.error);
}
EOF
    
    print_status "Test example created"
}

# Create .gitignore
create_gitignore() {
    print_info "Creating .gitignore file..."
    
    cat > .gitignore << 'EOF'
# Deno + Playwright .gitignore

# Deno specific
deno.lock
.deno/

# Node modules (if using npm packages)
node_modules/
package-lock.json
yarn.lock

# Playwright specific
/test-results/
/playwright-report/
/blob-report/
/playwright/.cache/

# Screenshots and media files (optional - uncomment if you don't want to commit them)
# screenshots/
# *.png
# *.jpg
# *.jpeg
# *.gif
# *.mp4
# *.webm

# Test artifacts
test-results/
coverage/
*.lcov

# Environment files
.env
.env.local
.env.development
.env.test
.env.production

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Temporary folders
tmp/
temp/
.tmp/

# Build outputs
dist/
build/
out/

# Cache directories
.cache/
.parcel-cache/

# Backup files
*.bak
*.backup
*.old

# Local development files
.local/
local/

# Browser downloads directory (if created by tests)
downloads/

# Custom ignore patterns (add your own below)
# my-custom-file.txt
EOF
    
    print_status ".gitignore created"
}

# Create README
create_readme() {
    print_info "Creating comprehensive README..."
    
    cat > README.md << 'EOF'
# Deno + Playwright Setup

This project provides a complete setup for using Playwright with Deno for web automation, scraping, and testing.

## 🚀 Quick Start

Run the one-click setup:
```bash
chmod +x tools-setup-playwright-in-deno.sh
./tools-setup-playwright-in-deno.sh
```

## 📁 Project Structure

```
├── examples/
│   ├── basic-example.ts      # Basic Playwright usage
│   └── scraper-example.ts    # Web scraping example
├── tests/
│   └── simple-test.ts        # Simple automated tests
├── screenshots/              # Generated screenshots
├── deno.json                 # Deno configuration
├── .gitignore                # Git ignore patterns
└── README.md                 # This file
```

## 🎯 Available Commands

```bash
# Run basic example
deno task example

# Run web scraper
deno task scrape

# Run automated tests
deno task test

# Install/update browsers
deno task install-browsers
```

## 🔧 Manual Execution

You can also run scripts directly:
```bash
deno run --allow-net --allow-read --allow-write --allow-run --allow-env --allow-sys examples/basic-example.ts
```

## 🛡️ Required Permissions

Playwright with Deno requires these permissions:
- `--allow-net` - Network access for web requests
- `--allow-read` - Read files and directories  
- `--allow-write` - Write screenshots and files
- `--allow-run` - Run browser processes
- `--allow-env` - Access environment variables
- `--allow-sys` - System information access

## 🌐 Browser Support

This setup includes:
- **Chromium** (default in examples)
- **Firefox** 
- **WebKit** (Safari)

To use different browsers:
```typescript
import { firefox, webkit } from "playwright";
```

## 💡 Common Use Cases

1. **Web Scraping**: Extract data from websites
2. **Automated Testing**: Test web applications  
3. **Screenshot Generation**: Capture page screenshots
4. **PDF Generation**: Convert pages to PDF
5. **Performance Testing**: Measure page load times
6. **Form Automation**: Fill and submit forms
7. **Content Monitoring**: Track website changes

## 🎨 Examples Included

### Basic Example
- Navigate to websites
- Take screenshots
- Extract page content
- Handle basic interactions

### Web Scraper
- Scrape Hacker News stories
- Extract structured data
- Handle dynamic content
- Save results

### Automated Tests
- Google search functionality
- Form submission testing
- Screenshot capture
- Test result reporting

## 🔍 Tips & Best Practices

- Use `headless: true` for server environments
- Use `headless: false` for debugging (requires display)
- Set viewport size for consistent screenshots
- Use `page.waitForSelector()` for dynamic content
- Handle errors with try-catch blocks
- Use `page.waitForLoadState()` for better reliability
- Implement proper timeouts for network requests

## 📦 Git Usage

The project includes a comprehensive `.gitignore` file that:

**Files that ARE committed:**
- Source code (`.ts` files)
- Configuration (`deno.json`, `README.md`)
- Documentation and examples

**Files that are NOT committed:**
- `deno.lock` (auto-generated)
- `node_modules/` (if using npm packages)
- Browser cache and test artifacts
- Environment files (`.env`)
- IDE-specific files
- OS-generated files

**Optional (commented out by default):**
- Screenshots and media files - uncomment in `.gitignore` if you don't want to commit them

## 🐛 Troubleshooting

### Browser Installation Issues
```bash
deno task install-browsers
```

### Permission Errors
Make sure all required permissions are granted in your deno.json tasks.

### Display Issues (Linux)
For headless environments, ensure `headless: true` is set in browser launch options.

## 📚 Resources

- [Deno Documentation](https://deno.land/manual)
- [Playwright Documentation](https://playwright.dev/)
- [Playwright with Deno Examples](https://github.com/microsoft/playwright)

## 🤝 Contributing

Feel free to add more examples and improve the existing ones!
EOF
    
    print_status "README created"
}

# Install Playwright browsers
install_browsers() {
    print_info "Installing Playwright browsers..."
    print_warning "This may take a few minutes..."
    
    if npx playwright@1.40.0 install; then
        print_status "Playwright browsers installed successfully"
    else
        print_error "Failed to install Playwright browsers"
        print_info "You can try again later with: deno task install-browsers"
    fi
}

# Test the setup
test_setup() {
    print_info "Testing the setup..."
    
    if deno task example; then
        print_status "Setup test completed successfully!"
    else
        print_warning "Setup test had issues, but the installation is complete"
    fi
}

# Main setup function
main() {
    echo ""
    print_info "Starting one-click Deno + Playwright setup..."
    echo ""
    
    check_deno
    create_project_structure
    create_deno_config
    create_basic_example
    create_scraper_example
    create_test_example
    create_gitignore
    create_readme
    install_browsers
    test_setup
    
    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    print_status "Deno + Playwright environment is ready!"
    echo ""
    print_info "Try these commands:"
    echo "  deno task example  # Run basic example"
    echo "  deno task scrape   # Run web scraper"  
    echo "  deno task test     # Run automated tests"
    echo ""
    print_info "Check the README.md for detailed documentation"
    echo ""
}

# Run main function
main "$@"
EOF
    
    print_status "One-click setup script created"
}

# Make the script executable
<function_calls>
<invoke name="execute_bash">
<parameter name="command">chmod +x /home/ln5/dev--path/v02--pw-setup/tools-setup-playwright-in-deno.sh
