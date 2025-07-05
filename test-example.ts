import { chromium, Browser, Page } from "playwright";

class WebTester {
  private browser: Browser | null = null;
  private page: Page | null = null;

  async setup() {
    this.browser = await chromium.launch({ headless: true });
    const context = await this.browser.newContext();
    this.page = await context.newPage();
  }

  async teardown() {
    if (this.browser) {
      await this.browser.close();
    }
  }

  async testGoogleSearch() {
    if (!this.page) throw new Error("Page not initialized");

    console.log("🔍 Testing Google Search...");
    
    // Navigate to Google
    await this.page.goto("https://www.google.com");
    
    // Accept cookies if present
    try {
      await this.page.click('button:has-text("Accept all")', { timeout: 2000 });
    } catch {
      // Cookie banner might not be present
    }

    // Search for "Deno Playwright"
    await this.page.fill('input[name="q"]', "Deno Playwright");
    await this.page.press('input[name="q"]', "Enter");
    
    // Wait for results
    await this.page.waitForSelector("#search");
    
    // Check if results contain expected text
    const resultsText = await this.page.textContent("#search");
    const hasDenoResults = resultsText?.toLowerCase().includes("deno");
    const hasPlaywrightResults = resultsText?.toLowerCase().includes("playwright");
    
    console.log(`✅ Search results contain 'deno': ${hasDenoResults}`);
    console.log(`✅ Search results contain 'playwright': ${hasPlaywrightResults}`);
    
    // Take screenshot of results
    await this.page.screenshot({ path: "google-search-results.png" });
    console.log("📸 Search results screenshot saved");
    
    return hasDenoResults && hasPlaywrightResults;
  }

  async testFormInteraction() {
    if (!this.page) throw new Error("Page not initialized");

    console.log("\n📝 Testing form interaction...");
    
    // Navigate to a form testing site
    await this.page.goto("https://httpbin.org/forms/post");
    
    // Fill out the form
    await this.page.fill('input[name="custname"]', "John Doe");
    await this.page.fill('input[name="custtel"]', "123-456-7890");
    await this.page.fill('input[name="custemail"]', "john@example.com");
    await this.page.selectOption('select[name="size"]', "medium");
    await this.page.check('input[name="topping"][value="bacon"]');
    await this.page.fill('textarea[name="comments"]', "Test comment from Deno Playwright");
    
    // Submit the form
    await this.page.click('input[type="submit"]');
    
    // Wait for response page
    await this.page.waitForSelector("pre");
    
    // Check if form data was submitted correctly
    const responseText = await this.page.textContent("pre");
    const hasFormData = responseText?.includes("John Doe") && responseText?.includes("john@example.com");
    
    console.log(`✅ Form submission successful: ${hasFormData}`);
    
    return hasFormData;
  }
}

async function runTests() {
  const tester = new WebTester();
  
  try {
    await tester.setup();
    
    const searchTest = await tester.testGoogleSearch();
    const formTest = await tester.testFormInteraction();
    
    console.log("\n🎯 Test Results:");
    console.log("================");
    console.log(`Google Search Test: ${searchTest ? "PASSED" : "FAILED"}`);
    console.log(`Form Interaction Test: ${formTest ? "PASSED" : "FAILED"}`);
    console.log(`Overall: ${searchTest && formTest ? "ALL TESTS PASSED ✅" : "SOME TESTS FAILED ❌"}`);
    
  } catch (error) {
    console.error("❌ Test execution failed:", error);
  } finally {
    await tester.teardown();
  }
}

if (import.meta.main) {
  runTests().catch(console.error);
}
