import { chromium } from "playwright";

async function runSimpleTests() {
  console.log("🧪 Running simple Playwright tests...");
  console.log("=" .repeat(40));
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  const results: { [key: string]: boolean } = {};
  
  try {
    // Test 1: Navigate to example.com
    console.log("🌐 Test 1: Navigation test...");
    await page.goto("https://example.com");
    const title = await page.title();
    results.navigation = title.includes("Example");
    console.log(`✅ Navigation test: ${results.navigation ? "PASSED" : "FAILED"}`);
    
    // Test 2: Screenshot test
    console.log("📸 Test 2: Screenshot test...");
    await page.screenshot({ path: "screenshots/test-screenshot.png" });
    results.screenshot = true; // If we get here, screenshot worked
    console.log(`✅ Screenshot test: PASSED`);
    
    // Test 3: Content extraction test
    console.log("📝 Test 3: Content extraction test...");
    const content = await page.textContent("body");
    results.contentExtraction = content !== null && content.length > 0;
    console.log(`✅ Content extraction test: ${results.contentExtraction ? "PASSED" : "FAILED"}`);
    
    // Test 4: Element interaction test
    console.log("🔗 Test 4: Element interaction test...");
    const links = await page.$$eval("a", (anchors) => anchors.length);
    results.elementInteraction = links > 0;
    console.log(`✅ Element interaction test: ${results.elementInteraction ? "PASSED" : "FAILED"}`);
    
  } catch (error) {
    console.error("❌ Test execution error:", error);
  } finally {
    await browser.close();
  }
  
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
    console.log("🎉 All tests passed! Playwright setup is working correctly.");
  } else {
    console.log("⚠️  Some tests failed.");
  }
}

if (import.meta.main) {
  runSimpleTests().catch(console.error);
}
