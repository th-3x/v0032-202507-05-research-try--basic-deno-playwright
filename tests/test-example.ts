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
