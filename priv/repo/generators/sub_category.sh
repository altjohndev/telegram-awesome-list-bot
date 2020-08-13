mix phx.gen.live Listings SubCategory sub_categories \
  id:uuid:unique \
  chat:references:chats \
  category:references:categories \
  name:string \
  abbr:string \
  description:string
