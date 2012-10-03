#================
# Chat Room Pages
#================

#
class ChatRoom < BasePage

  frame_element

  value(:total_messages_shown) { |b| b.frame(:class=>"wcwmenu").div(:id=>"chat2_messages_shown_total").text }

  action(:options) { |b| b.frm.link(text: "Options").click }

end

class ManageRooms < BasePage

  frame_element

  action(:add_room) { |b| b.frm.link(text: "Add Room").click }

end