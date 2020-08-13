mix phx.gen.live Listings Item items \
  id:uuid:unique \
  chat:references:chats \
  category:references:categories \
  sub_category:references:sub_categories \
  name:string \
  abbr:string \
  description:string \
  reference:string \
  selected:boolean \
  archived:boolean
