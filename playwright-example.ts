import { chromium } from "npm:playwright@1.40.0";

async function main() {
  // Launch browser in headless mode
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to a page
  await page.goto("https://example.com");
  
  // Take a screenshot
  await page.screenshot({ path: "example.png" });
  
  // Get page title
  const title = await page.title();
  console.log(`Page title: ${title}`);

  // Close browser
  await browser.close();
  
  console.log("✅ Playwright with Deno setup successful!");
  console.log("📸 Screenshot saved as example.png");
}

if (import.meta.main) {
  main().catch(console.error);
}
