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
