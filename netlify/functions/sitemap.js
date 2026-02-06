// صفحات ثابتة مهمة
urls += `
<url><loc>https://tactical729.com/#/categories</loc></url>
<url><loc>https://tactical729.com/#/products</loc></url>
<url><loc>https://tactical729.com/#/cart</loc></url>
<url><loc>https://tactical729.com/#/orders</loc></url>
`;


const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

exports.handler = async function () {
  try {
    // ===============================
    // ✅ Fetch Categories
    // ===============================
    const { data: categories, error: catError } = await supabase
      .from("categories")
      .select("slug, updated_at");

    if (catError) throw catError;

    // ===============================
    // ✅ Fetch Products
    // ===============================
    const { data: products, error: prodError } = await supabase
      .from("products")
      .select("slug, updated_at");

    if (prodError) throw prodError;

    // ===============================
    // ✅ Sitemap URLs Builder
    // ===============================
    let urls = "";

    // 🏠 Homepage
    urls += `
  <url>
    <loc>https://tactical729.com/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>`;

    // ===============================
    // ✅ Category Pages
    // ===============================
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
    <priority>0.9</priority>
  </url>`;
    });

    // ===============================
    // ✅ Product Pages
    // ===============================
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
    <priority>0.8</priority>
  </url>`;
    });

    // ===============================
    // ✅ Final XML Output
    // ===============================
    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/xml",
      },
      body: sitemap,
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: `❌ Error generating sitemap: ${err.message}`,
    };
  }
};
