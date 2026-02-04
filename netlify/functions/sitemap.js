const { createClient } = require("@supabase/supabase-js");

/* ===============================
   Tactical 729 Dynamic Sitemap
   Generated Automatically
   =============================== */

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

exports.handler = async function () {
  try {
    /* ===============================
       1) Fetch Categories
       =============================== */
    const { data: categories, error: catError } = await supabase
      .from("categories")
      .select("slug, updated_at");

    if (catError) throw catError;

    /* ===============================
       2) Fetch Products
       =============================== */
    const { data: products, error: prodError } = await supabase
      .from("products")
      .select("slug, updated_at");

    if (prodError) throw prodError;

    /* ===============================
       3) Sitemap XML Start
       =============================== */
    let urls = "";

    // ✅ Homepage
    urls += `
  <url>
    <loc>https://tactical729.com/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>`;

    // ✅ Main Pages
    const mainPages = [
      { path: "#/categories", priority: 0.9 },
      { path: "#/products", priority: 0.9 },
      { path: "#/cart", priority: 0.7 },
      { path: "#/orders", priority: 0.6 },
    ];

    mainPages.forEach((page) => {
      urls += `
  <url>
    <loc>https://tactical729.com/${page.path}</loc>
    <changefreq>weekly</changefreq>
    <priority>${page.priority}</priority>
  </url>`;
    });

    /* ===============================
       4) Category Pages
       =============================== */
    categories?.forEach((cat) => {
      if (!cat.slug) return;

      const lastmod = cat.updated_at
        ? cat.updated_at.split("T")[0]
        : new Date().toISOString().split("T")[0];

      urls += `
  <url>
    <loc>https://tactical729.com/#/category/${cat.slug}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.85</priority>
  </url>`;
    });

    /* ===============================
       5) Product Pages (Most Important)
       =============================== */
    products?.forEach((p) => {
      if (!p.slug) return;

      const lastmod = p.updated_at
        ? p.updated_at.split("T")[0]
        : new Date().toISOString().split("T")[0];

      urls += `
  <url>
    <loc>https://tactical729.com/#/product/${p.slug}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.95</priority>
  </url>`;
    });

    /* ===============================
       6) Final XML Output
       =============================== */
    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/xml",
        "Cache-Control": "no-cache",
      },
      body: sitemap,
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: `Error generating sitemap: ${err.message}`,
    };
  }
};
