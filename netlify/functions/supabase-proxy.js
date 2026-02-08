exports.handler = async (event) => {
  const SUPABASE_URL =
    "https://vpychjqluwggrhyqllbu.supabase.co/rest/v1/offers?select=*";

  const response = await fetch(SUPABASE_URL, {
    headers: {
      apikey: process.env.SUPABASE_ANON_KEY,
      Authorization: `Bearer ${process.env.SUPABASE_ANON_KEY}`,
    },
  });

  const data = await response.json();

  return {
    statusCode: 200,
    body: JSON.stringify(data),
  };
};
