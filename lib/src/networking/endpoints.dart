import 'package:robin_flutter/src/utils/constants.dart';

const createUserTokenUrl = '$httpUrl/chat/user_token';
const getDetailsFromUserTokenUrl = '$httpUrl/chat/user_token';

const createConversationUrl = '$httpUrl/conversation';
const getConversationMessagesUrl = '$httpUrl/conversation/messages';
const createGroupChatUrl = '$httpUrl/chat/conversation/group';
const assignGroupModeratorUrl = '$httpUrl/chat/conversation/group/assign_moderator';
const addGroupParticipantsUrl = '$httpUrl/chat/conversation/group/add_participants';
const removeGroupParticipantUrl = '$httpUrl/chat/conversation/group/remove_participants';
const archiveConversationUrl = '$httpUrl/conversation/archive';
const unarchiveConversationUrl = '$httpUrl/conversation/unarchive';
const forwardMessagesUrl = '$httpUrl/conversation/forward_messages';

const deleteMessagesUrl = '$httpUrl/chat/message';
const sendAttachmentUrl = '$httpUrl/chat/message/send/attachment';
const replyWithAttachmentUrl = '$httpUrl/chat/message/send/attachment/reply';
const sendReactionUrl = '$httpUrl/chat/message/reaction';
const removeReactionUrl = '$httpUrl/chat/message/reaction/delete';
const sendReadReceiptsUrl = '$httpUrl/chat/message/read/receipt';