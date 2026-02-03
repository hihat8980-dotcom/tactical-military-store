const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

exports.handler = async function () {
  try {
    // ✅ جلب الأقسام
    const { data: categories, error: catError } = await supabase
      .from("categories")
      .select("slug");

    if (catError) throw catError;

    // ✅ جلب المنتجات
    const { data: products, error: prodError } = await supabase
      .from("products")
      .select("slug, updated_at");

    if (prodError) throw prodError;

    // ✅ روابط Sitemap
    let urls = "";

    // الصفحة الرئيسية
    urls += `
  <url>
    <loc>https://tactical729.com/</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>`;

    // صفحات الأقسام
    categories?.forEach((cat) => {
      if (!cat.slug) return;

      urls += `
  <url>
    <loc>https://tactical729.com/category/${cat.slug}</loc>
    <changefreq>weekly</changefreq>
    <priority>0.9</priority>
  </url>`;
    });

    // صفحات المنتجات
    products?.forEach((p) => {
      if (!p.slug) return;

      const lastmod = p.updated_at
        ? p.updated_at.split("T")[0]
        : new Date().toISOString().split("T")[0];

      urls += `
  <url>
    <loc>https://tactical729.com/product/${p.slug}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>`;
    });

    // ✅ إخراج Sitemap كامل
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
      body: `Error generating sitemap: ${err.message}`,
    };
  }
};
