exports.handler = async () => {
  const SUPABASE_URL =
    "https://vpychjqluwggrhyqllbu.supabase.co/rest/v1/offers?select=*";

  const response = await fetch(SUPABASE_URL, {
    headers: {
      apikey: process.env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  const data = await response.text();

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: data,
  };
};
