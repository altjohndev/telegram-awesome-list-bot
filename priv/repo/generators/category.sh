mix phx.gen.live Listings Category categories \
  id:uuid:unique \
  chat:references:chats \
  name:string \
  abbr:string \
  description:string
