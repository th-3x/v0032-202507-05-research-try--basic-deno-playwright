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
