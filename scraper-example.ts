import { chromium } from "playwright";

async function scrapeExample() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate to a news website
    console.log("🌐 Navigating to Hacker News...");
    await page.goto("https://news.ycombinator.com");

    // Wait for content to load
    await page.waitForSelector(".titleline");

    // Extract top stories
    const stories = await page.evaluate(() => {
      const titleElements = document.querySelectorAll(".titleline > a");
      return Array.from(titleElements)
        .slice(0, 5) // Get top 5 stories
        .map((element) => ({
          title: element.textContent?.trim() || "",
          url: element.getAttribute("href") || "",
        }));
    });

    console.log("\n📰 Top 5 Hacker News Stories:");
    console.log("================================");
    stories.forEach((story, index) => {
      console.log(`${index + 1}. ${story.title}`);
      console.log(`   ${story.url.startsWith("http") ? story.url : "https://news.ycombinator.com/" + story.url}`);
      console.log("");
    });

    // Take a screenshot
    await page.screenshot({ path: "hackernews.png", fullPage: true });
    console.log("📸 Screenshot saved as hackernews.png");

  } catch (error) {
    console.error("❌ Error during scraping:", error);
  } finally {
    await browser.close();
  }
}

if (import.meta.main) {
  scrapeExample().catch(console.error);
}
