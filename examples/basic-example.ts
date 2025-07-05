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
    
    console.log("✅ Basic example completed successfully!");
    
  } catch (error) {
    console.error("❌ Error in basic example:", error);
  } finally {
    await browser.close();
  }
}

if (import.meta.main) {
  basicExample().catch(console.error);
}
